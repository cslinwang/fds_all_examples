#!/bin/bash

# 输入
git_sha="${1:-ec52dee4274fcf994d358c8b0f883eec8f67e041}"
git_version="${2:-FDS6.7.9}"

# 获取脚本的绝对路径
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"
# 清楚日志
rm -rf ./run_log.log
exec &> >(tee -a "./run_log.log")

# 1. 编译当前版本的FDS
echo "开始编译FDS..."
# ./compile_fds.sh $git_sha

# 2. 循环运行样例
# 2.1 获取样例列表
testcase_list=$(find /home/my/fds/Verification /home/my/fds/Validation -name "*.fds")
# 统计样例数量
# 计算总的测试用例数
total_cases=$(echo "$testcase_list" | wc -l)
# 初始化计数器
count=0

# 设置起始和终止参数
start=1966
end=2528

echo "总共有 $total_cases 个测试用例。"
echo -ne '测试用例运行进度: [--------------------] (0%, 0/'$total_cases')\r'

for testcase in $testcase_list; do
    # 检测当前服务器存储，如果剩余空间小于1G，退出
    free_space=$(df -m /home/my | tail -1 | awk '{print $4}')
    if [ $free_space -lt 1024 ]; then
        echo -e "\n服务器存储空间不足1G，重新编译。"
        # 重新编译
        cd /home/my/fds/
        git reset --hard HEAD
        git clean -fdx
        cd "$SCRIPT_DIR"
        ./compile_fds.sh $git_sha
        # 重新查看剩余空间
        free_space=$(df -m /home/my | tail -1 | awk '{print $4}')
        if [ $free_space -lt 1024 ]; then
            echo -e "\n服务器存储空间不足1G，退出。"
            exit 1
        fi
    fi
    # 更新计数器
    ((count++))
    # 检查是否在指定范围内
    if [ $count -ge $start ] && [ $count -le $end ]; then
        echo "执行 $count"
    else
        echo "跳过 $count"
        continue
    fi
    # 读取用例列表，如果在列表中，则运行。否则跳过
    # 读取




    # 删除历史中间文件

    cd /home/my/fds/
    git clean -f -d /home/my/fds/Verification
    git clean -f -d /home/my/fds/Validation
    cd "$SCRIPT_DIR"

    # 获取testcase名称
    testcase_name=$(basename $testcase)
    testcase_name=${testcase_name%.*}

    # 创建保存覆盖率的文件夹
    testcase_coverage_save_path="/home/my/fds_coverage/$git_version/$testcase_name"
    mkdir -p $testcase_coverage_save_path

    echo "开始运行样例 $testcase_name"
    exit -1

    # 检查覆盖率文件是否已存在
    coverage_file="$testcase_coverage_save_path/report.json"  # 请替换为你的实际覆盖率文件名
    if [ -f "$coverage_file" ]; then
        echo "覆盖率文件已存在，跳过 $testcase_name"
    else
        echo "开始运行样例 $testcase_name"
        # 运行测试用例并设置超时时间
        timeout 1200s ./run_testcase_coverage.sh "$testcase" "$testcase_coverage_save_path"
        if [ $? -eq 124 ]; then
            echo -e "\n命令超时"
            touch "$testcase_coverage_save_path/report.json"
        else
            echo -e "\n样例 $testcase_name 运行完成。"
            fi

    fi
    # 计算进度
    percent=$((100 * count / total_cases))
    bar=$(printf "%0.s#" $(seq 1 $((percent / 5))))
    empty_bar=$(printf "%0.s-" $(seq 1 $((20 - percent / 5))))

    # 打印进度
    echo -ne "测试用例运行进度: [$bar$empty_bar] ($percent%, $count/$total_cases)\r"

done

echo -e "\n所有测试用例运行完毕。"

aAA# End of script.
