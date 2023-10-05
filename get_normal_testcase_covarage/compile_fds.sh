#!/bin/bash


full_sha="$1"
is_fortan_replaced="${2:---none}"
mpirun_n="${3:-1}"
build_dir="${4:-ompi_gnu_linux}"
is_build="false"

echo "切换分支开始..."

# Extract short SHA from full SHA.
short_sha=$(echo "$full_sha" | cut -c 1-7)

# Reset repository and checkout master branch.
cd ~/fds
git reset --hard HEAD
git clean -fd
git checkout master

# Delete branch if it exists.
if git show-ref --quiet "refs/heads/$short_sha"; then
  git branch -D "$short_sha"
fi

# Create a new branch based on the specified SHA.
git checkout -b "$short_sha" "$full_sha"

echo "已切换到分支 $short_sha。"
echo "开始修改makefile，以支持代码覆盖率..."

# Replace compile options in makefile to support gcov.
# File path.
makefile="Build/makefile"

# Check if file exists.
if [ ! -f "$makefile" ]; then
    echo "File $makefile does not exist!"
    exit 1
fi

# 增加代码覆盖率选项
# mpi_gnu_linux_64 : FFLAGS = -m64 -O2 -std=f2008 -ffpe-summary=none -fall-intrinsics $(GITINFOGNU) $(GNU_COMPINFO) $(FFLAGSMKL_GNU_OPENMPI)
search1="mpi_gnu_linux_64 : FFLAGS = -m64 -O2 -std=f2008 -ffpe-summary=none -fall-intrinsics \$(GITINFOGNU) \$(GNU_COMPINFO) \$(FFLAGSMKL_GNU_OPENMPI)"
replace1="mpi_gnu_linux_64 : FFLAGS = -m64 -O2 -std=f2008 -ffpe-summary=none -fall-intrinsics -fprofile-arcs -ftest-coverage \$(GITINFOGNU) \$(GNU_COMPINFO) \$(FFLAGSMKL_GNU_OPENMPI)"

# ompi_gnu_linux : FFLAGS = -m64 -O2 -std=f2018 -frecursive -ffpe-summary=none -fall-intrinsics $(GITINFOGNU) $(GNU_COMPINFO) $(FFLAGSMKL_GNU_OPENMPI) $(GFORTRAN_OPTIONS)
search2="ompi_gnu_linux : FFLAGS = -m64 -O2 -std=f2018 -frecursive -ffpe-summary=none -fall-intrinsics \$(GITINFOGNU) \$(GNU_COMPINFO) \$(FFLAGSMKL_GNU_OPENMPI) \$(GFORTRAN_OPTIONS)"
replace2="ompi_gnu_linux : FFLAGS = -m64 -O2 -std=f2018 -frecursive -ffpe-summary=none -fall-intrinsics -fprofile-arcs -ftest-coverage \$(GITINFOGNU) \$(GNU_COMPINFO) \$(FFLAGSMKL_GNU_OPENMPI) \$(GFORTRAN_OPTIONS)"

# mpi_gnu_linux_64 : FFLAGS = -m64 -O2 -std=f2018 -frecursive -ffpe-summary=none -fall-intrinsics $(GITINFOGNU) $(GNU_COMPINFO) $(FFLAGSMKL_GNU_OPENMPI) $(GFORTRAN_OPTIONS)
search3="mpi_gnu_linux_64 : FFLAGS = -m64 -O2 -std=f2018 -frecursive -ffpe-summary=none -fall-intrinsics \$(GITINFOGNU) \$(GNU_COMPINFO) \$(FFLAGSMKL_GNU_OPENMPI) \$(GFORTRAN_OPTIONS)"
replace3="mpi_gnu_linux_64 : FFLAGS = -m64 -O2 -std=f2018 -frecursive -ffpe-summary=none -fall-intrinsics -fprofile-arcs -ftest-coverage \$(GITINFOGNU) \$(GNU_COMPINFO) \$(FFLAGSMKL_GNU_OPENMPI) \$(GFORTRAN_OPTIONS)"

# mpi_gnu_linux_64 : FFLAGS = -m64 -O2 -std=f2008 -frecursive -ffpe-summary=none -fall-intrinsics $(GITINFOGNU) $(GNU_COMPINFO) $(FFLAGSMKL_GNU_OPENMPI)
search4="mpi_gnu_linux_64 : FFLAGS = -m64 -O2 -std=f2008 -frecursive -ffpe-summary=none -fall-intrinsics \$(GITINFOGNU) \$(GNU_COMPINFO) \$(FFLAGSMKL_GNU_OPENMPI)"
replace4="mpi_gnu_linux_64 : FFLAGS = -m64 -O2 -std=f2008 -frecursive -ffpe-summary=none -fall-intrinsics -fprofile-arcs -ftest-coverage \$(GITINFOGNU) \$(GNU_COMPINFO) \$(FFLAGSMKL_GNU_OPENMPI)"

# mpi_gnu_linux_64 : FFLAGS = -O3 $(GITINFOGNU)
search5="mpi_gnu_linux_64 : FFLAGS = -O3 \$(GITINFOGNU)"
replace5="mpi_gnu_linux_64 : FFLAGS = -O3 -fprofile-arcs -ftest-coverage \$(GITINFOGNU)"

# mpi_gnu_linux_64 : FFLAGS = -m64 -O2 -ffpe-summary=none $(GITINFOGNU) $(GNU_COMPINFO) $(FFLAGSMKL_GNU_OPENMPI)
search6="mpi_gnu_linux_64 : FFLAGS = -m64 -O2 -ffpe-summary=none \$(GITINFOGNU) \$(GNU_COMPINFO) \$(FFLAGSMKL_GNU_OPENMPI)"
replace6="mpi_gnu_linux_64 : FFLAGS = -m64 -O2 -ffpe-summary=none -fprofile-arcs -ftest-coverage \$(GITINFOGNU) \$(GNU_COMPINFO) \$(FFLAGSMKL_GNU_OPENMPI)"

# mpi_gnu_linux_64 : FFLAGS = -m64 -O2 -std=f2008 -ffpe-summary=none $(GITINFOGNU) $(GNU_COMPINFO) $(FFLAGSMKL_GNU_OPENMPI)
search7="mpi_gnu_linux_64 : FFLAGS = -m64 -O2 -std=f2008 -ffpe-summary=none \$(GITINFOGNU) \$(GNU_COMPINFO) \$(FFLAGSMKL_GNU_OPENMPI)"
replace7="mpi_gnu_linux_64 : FFLAGS = -m64 -O2 -std=f2008 -ffpe-summary=none -fprofile-arcs -ftest-coverage \$(GITINFOGNU) \$(GNU_COMPINFO) \$(FFLAGSMKL_GNU_OPENMPI)"


# Check if the content to be replaced is found in the file
grep -qF -- "$search1" "$makefile"
found1=$?
grep -qF -- "$search2" "$makefile"
found2=$?
grep -qF -- "$search3" "$makefile"
found3=$?
grep -qF -- "$search4" "$makefile"
found4=$?
grep -qF -- "$search5" "$makefile"
found5=$?
grep -qF -- "$search6" "$makefile"
found6=$?
grep -qF -- "$search7" "$makefile"
found7=$?

# If the content to be replaced is found, perform the replacement; otherwise, print an error message and exit
if [ $found1 -eq 0 -o $found2 -eq 0 -o $found3 -eq 0 -o $found4 -eq 0 -o $found5 -eq 0 -o $found6 -eq 0 -o $found7 -eq 0 ]; then
    sed -i.bak "s~$search1~$replace1~g;s~$search2~$replace2~g;s~$search3~$replace3~g;s~$search4~$replace4~g;s~$search5~$replace5~g;s~$search6~$replace6~g;s~$search7~$replace7~g" "$makefile"
    echo "代码覆盖率编译选项替换完成。"
else
    echo "错误： 未找到匹配的编译选项。请联系脚本作者。"
    echo "ERROR: No matching compile options found."
    exit 1
fi

# 替换foran18的内容
if [ "$is_fortan_replaced" == "--fortran18" ]; then
    echo "开始替换foran18内容..."
    for file in $(find ./Source -type f); do
        sed -i 's/IMPLICIT NONE (TYPE,EXTERNAL)/IMPLICIT NONE/g' $file
    done
    echo "foran18 替换完成。"
elif [ "$is_fortan_replaced" != "--none" ]; then
    echo "参数错误：'$is_fortan_replaced' 是无效的参数。请重新运行脚本并在第五个参数位置输入 --fortran18 进行替换。"
    exit 1
# else
    # echo "没有进行替换。如果需要替换，重新运行脚本并在第五个参数位置输入 foran18。"
fi


# Check if make_fds.sh exists in the specified build directory.
if ls "Build/$build_dir" &>/dev/null && [ -f "Build/$build_dir/make_fds.sh" ]; then
  # Remove all files except for .sh files in the build directory.
  find "Build/$build_dir" ! -name '*.sh' -type f -exec rm {} +

  # Build the FDS executable.
  cd "Build/$build_dir"
  # Copy gcov make_fds.sh to target directory.
  rm make_fds.sh
  cp /home/my/fds_all_examples/make_fds.sh .
  ./make_fds.sh
  is_build="true"
  echo "编译完成。"

# else
#   echo "Makefile or make_fds.sh not found in Build/$build_dir directory."
fi

# Check if make_fds.sh exists in the mpi_gnu_linux_64 directory.
build_dir="mpi_gnu_linux_64"

if ls "Build/$build_dir" &>/dev/null && [ -f "Build/$build_dir/make_fds.sh" ]; then
  # Remove all files except for .sh files in the build directory.
  find "Build/$build_dir" ! -name '*.sh' -type f -exec rm {} +

  # Build the FDS executable.
  cd "Build/$build_dir"
  # Copy gcov make_fds.sh to target directory.
  rm make_fds.sh
  cp /home/my/fds_all_examples/make_fds.sh .
  ./make_fds.sh
  is_build="true"
  echo "编译完成。"

# else
#   echo "Makefile or make_fds.sh not found in Build/$build_dir directory."
fi

# Check if no build is found
if [ "$is_build" = "false" ]; then
  echo "在指定的目录中未找到编译文件, 请联系脚本作者。"
  echo "No build found in the specified directory."
fi

# 循环运行样例

# End of script.
