# 本地消息表（Transactional Outbox）防御模式

面试中常被追问"微服务间怎么保证数据一致性？需要分布式事务吗？"

## 核心判断：不是所有跨服务调用都需要分布式事务

先把跨服务联动分类：

| 联动场景 | 业务语义 | 需要分布式事务？ |
|----------|---------|:---:|
| A 完成后 B 必须最终被执行（但 A 不回滚） | 编排/最终一致性 | ❌ 本地消息表 |
| A 和 B 必须同时成功或同时回滚 | 强一致性 | ✅ SAGA/TCC |

多数业务场景是前者——合同签了就是签了，白条创建失败应重试而非回滚合同。

## 本地消息表模式

**三部分：同事务写入 + relay 异步投递 + 幂等消费**

```go
// 1. 生产者：业务 + 消息同事务写入（含 next_retry_at，新消息立即可被扫到）
func Sign(ctx, req) error {
    tx := db.Begin()
    tx.Exec("UPDATE contracts SET status='signed' WHERE id=?", req.ContractID)
    tx.Exec(`INSERT INTO outbox (id, event_type, payload, status, next_retry_at)
             VALUES (?, 'contract.signed', ?, 'pending', NOW())`,
             uuid.New(), json.Marshal(payload))
    return tx.Commit()  // 要么一起成功，要么一起回滚
}

// 2. Relay：后台 goroutine 轮询投递（多实例安全版）
func Run() {
    ticker := time.NewTicker(5 * time.Second)
    for range ticker.C {
        rows := db.Query(
            "SELECT * FROM outbox WHERE status='pending' AND next_retry_at <= NOW() " +
            "ORDER BY next_retry_at LIMIT 50 FOR UPDATE SKIP LOCKED")
        for _, msg := range rows {
            _, err := downstreamCli.Call(ctx, msg.Payload)
            if err == nil {
                db.Exec("UPDATE outbox SET status='sent' WHERE id=?", msg.ID)
            } else {
                // 指数退避：失败后推迟重试，避免饥饿阻塞后续消息
                db.Exec(`UPDATE outbox SET retry_count=retry_count+1,
                         next_retry_at=DATE_ADD(NOW(), INTERVAL POW(2, retry_count) MINUTE),
                         status=CASE WHEN retry_count>=5 THEN 'dead' ELSE 'pending' END
                         WHERE id=?`, msg.ID)
                // dead → Prometheus 告警 → 人工介入
            }
        }
    }
}
```

// 3. 消费者：幂等去重
func CreateWhitelabel(ctx, req) error {
    exists := db.QueryRow("SELECT id FROM whitelabels WHERE contract_id=?", req.ContractID)
    if exists != nil { return nil }  // 已处理
    return doCreate(ctx, req)
}
```

## 为什么不用 DTM？

防御要点：
- DTM 的 MSG（二阶段消息）本质上也是本地消息表模式
- 但 DTM 需要额外部署 DTM Server，增加运维负担
- 当前只有合同→白条一个跨服务异步场景，自建不到 100 行 Go 代码
- 如果未来跨服务场景增多或需要 SAGA 回滚语义，DTM 的 go-zero driver 可无缝升级

## 面试追问防御链

```
面试官: 微服务间怎么保证数据一致性？
  → 本地消息表：同事务写入 + relay 异步投递 + 幂等消费

  追问: 如果 relay 挂了怎么办？
  → outbox 表 status='pending' 的消息还在，relay 重启后继续投递

  追问: 如果下游服务处理成功但 relay 没收到确认？
  → 下游幂等：重复投递同一 contract_id，已创建直接返回成功

  追问: 为什么不用 DTM / Kafka？
  → 当前只有一个跨服务场景，自建更轻量。DTM 在技术雷达里

  追问: 合同服务多实例了，relay 会不会重复消费同一条消息？
  → FOR UPDATE SKIP LOCKED 行锁抢占，每个实例只拿自己锁到的消息
  → 配合 next_retry_at 退避：失败的消息推迟重试，不饥饿阻塞后面的新消息
```

## 多实例安全规则（relay 伪代码必须包含）

| 规则 | 代码体现 | 缺失会怎样 |
|------|---------|-----------|
| 消息认领（claim） | `FOR UPDATE SKIP LOCKED` | 多实例抢同一条消息，重复调下游 |
| 退避排序 | `AND next_retry_at <= NOW() ORDER BY next_retry_at` | 失败消息反复被扫到，新消息饥饿 |
| 指数退避 | `POW(2, retry_count)` 分钟 | 失败消息紧耦合重试，白白消耗资源 |
| 幂等去重 | `SELECT ... WHERE contract_id=?` | 重复投递创建重复数据 |

## 反面案例

❌ "微服务间都是独立闭环，没有联动" — 面试官会追问具体场景，一戳就破
❌ "我们用 DTM 的 SAGA 做分布式事务" — 如果实际只有编排场景，SAGA 的 compensate 逻辑写不出来
❌ "跨服务调用失败就重试" — 没有幂等保证，面试官会追问"重复创建怎么办"

## 正面案例

✅ "合同签署和创建白条是跨服务操作，用本地消息表保证最终一致性"
✅ "合同服务同一事务写入业务数据和 outbox 消息，relay goroutine 轮询投递"
✅ "白条服务用 contract_id 做幂等去重，重复投递不影响"
✅ "评估过 DTM，当前一个场景自建够用；未来场景增多时 go-zero driver 可无缝升级"
