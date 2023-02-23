### subconverter 转换订阅
1. 下载docker镜像，`docker pull tindy2013/subconverter`
2. 创建volume，`docker volume create subconverter-data`
3. 运行镜像，`docker run -d -v subconverter-data -p 25500:25500 --name sub tindy2013/subconverter`
4. 拷贝文件到 volume, `cp custom_groups.toml ${volume_path}/subconverter-data/_data/snippets/ && cp openclash.tpl ${volume_path/subconverter-data/_data/base/}`
5. 在profiles下，增加一个 `.ini` 文件，具体配置参考 [配置档案](https://github.com/tindy2013/subconverter/blob/master/README-cn.md#%E9%85%8D%E7%BD%AE%E6%A1%A3%E6%A1%88)
6. 修改 pref.toml 配置
   ```toml
    # 增加
    [[aliases]]
    uri = 'mysub'
    target = '/getprofile?name=profiles/my.ini&token=password'

    # 修改
    'snippets/groups.toml' => 'snippets/custom_groups.toml'
    [[ruleset]]
    enabled = true => enabled = false
    clash_rule_base = 'base/all_base.tpl' => clash_rule_base = 'base/openclash.tpl'
    ```