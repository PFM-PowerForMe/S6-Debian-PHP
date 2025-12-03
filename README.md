### 📦 环境变量配置说明

| 变量名 | 类型 | 默认值 | 示例 | 功能说明 |
| :--- | :---: | :---: | :--- | :--- |
| **CR_CADDY_REAL_IP** | String | `X-Forwarded-For` | `CF-Connecting-IP` | 设置反代时识别真实 IP 的请求头（如使用 Cloudflare 时修改） |
| **CR_CADDY_WORK_DIR** | String | `/var/www/` | `/var/www/aaa` | PHP 网站运行的根目录 |
| **CR_FPM_PM** | String | `static` | `dynamic` / `ondemand` | PHP-FPM 的进程管理模式 |
| **CR_PHP_TOTAL_MEM** | Integer | `512` | `1024` | PHP 与 FPM 可用的总内存基准大小 (MB)，用于自动计算各缓存与进程参数 |
| **CR_PHP_POST_MAX_SIZE** | String | `1024M` | `50M` | PHP 允许接收的 POST 数据最大体积 (`post_max_size`) |
| **CR_PHP_UPLOAD_MAX_FILESIZE** | String | `1024M` | `50M` | PHP 允许上传的最大单文件体积 (`upload_max_filesize`) |
| **CR_PHP_MAX_EXECUTION_TIME** | Integer | `300` | `60` | PHP 脚本最大执行超时时间，单位秒 (`max_execution_time`) |
| **CR_PHP_MAX_INPUT_TIME** | Integer | `300` | `60` | PHP 接收并解析输入数据的最大时间，单位秒 (`max_input_time`) |
| **CR_PHP_MAX_INPUT_VARS** | Integer | `9999` | `3000` | PHP 允许接收的最大表单变量数量 (`max_input_vars`) |
| **CR_PHP_OPCACHE_VALIDATE** | Integer | `0` | `1` | Opcache 是否检查文件更新。生产环境建议为 0 (最高性能)，开发环境设为 1 |

---
