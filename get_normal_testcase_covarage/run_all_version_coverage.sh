#!/bin/bash

# 获取脚本的绝对路径
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"
# 清除日志
log_path="./run_all_version_log.log"
rm -rf $log_path
exec &> >(tee -a $log_path)

# 删除所有覆盖率
# echo "删除历史覆盖率信息"
# rm -rf /home/my/fds_coverage

# 循环所有版本
# 1. 获取版本列表
git_hashes=(
    "ec52dee4274fcf994d358c8b0f883eec8f67e041"
    # "cfc502f85437bbfb35bd5ac8b19b86eeea736696"
    # "bac6600d09761ca9c858ad5e32f5276f4ba3f611"
    # "49d14aa4a1d28517e90013a3bf150f78b4aa962d"
    # "5ccea76d225537ef523709c97027cbf081f60108"
    # "14cc738f98632e4e7945d7e325f193180b021b8e"
    # "bfaa110f1c29c157bf5f00143925c6501dd9c79a"
    # "71f02560677bb87dace8c81f2e5b817d24e70c46"
    # "5064c500c065b7abc5a34e0ae569a7ad7ec61ec8"
    # "fe0d4ef38f955b2a298ac9124ea3d8f085704edd"
)
# 2. 循环版本列表
# 获取Git哈希数组的长度
total_hashes=${#git_hashes[@]}

# 初始化计数器
count=0

# 显示初始进度
echo -ne '版本进度: [--------------------] (0%, 0/'$total_hashes'))\r'

# 循环遍历Git哈希数组
for hash in "${git_hashes[@]}"; do
    # 更新计数器
    ((count++))

    echo $hash
    ./run_all_testcase_coverage.sh $hash $hash

    # 计算进度百分比
    percent=$((100 * count / total_hashes))

    # 绘制进度条
    bar=$(printf "%0.s#" $(seq 1 $((percent / 5))))
    empty_bar=$(printf "%0.s-" $(seq 1 $((20 - percent / 5))))

    # 更新进度条和百分比
    echo -ne "版本进度: [$bar$empty_bar] ($percent%, , $count/$total_hashes))\r"

    if [ $? -eq 0 ]; then
        echo -e "\n版本 $hash 运行完成。"
    else
        echo -e "\n版本 $hash 运行失败。"
    fi
done

# 输出完成信息
echo -e "\n所有版本运行完毕。"
