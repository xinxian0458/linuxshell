#!/bin/bash
unset PYTHONENV
unset PYTHONPATH
export PATH=/usr/local/bin:/usr/bin:/usr/local/sbin:/usr/sbin:/home/zhangjie0220/.local/bin:/home/zhangjie0220/bin
echo $PATH

echo `which python`
echo `python --version`
if [[ -f ./get-pip.py ]];then
    sudo chmod +x ./get-pip.py
else
    curl -sSL -o ./get-pip.py https://bootstrap.pypa.io/get-pip.py && sudo chmod +x ./get-pip.py
fi

python ./get-pip.py
if [[ $? -ne 0 ]]; then
    exit $?
fi
echo `which pip`
pip install virtualenv
if [[ $? -ne 0 ]]; then
    echo "virtual env failed"
fi
