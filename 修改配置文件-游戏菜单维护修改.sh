#!/bin/bash
#游戏维护菜单-修改配置文件
#比较古老的脚本和处理方式了，现在一般借助工具进行批量操作，而且大部分游戏已经通过GM实现了这些功能，如配置修改、版本发布、黑白名单、关开服

conf=serverlist.xml
AreaList=`awk -F '"' '/<s/{print $2}' $conf`

select area in $AreaList 全部 退出
do
    echo ""
    echo $area
    case $area in
    退出)
        exit
    ;;
    *)
        select operate in "修改版本号" "添加维护中" "删除维护中" "返回菜单"
        do
            echo ""
            echo $operate
            case $operate in
            修改版本号)
                echo 请输入版本号
                while read version
                do
                    if echo $version | grep -w 10[12][0-9][0-9][0-9][0-9][0-9][0-9]
                    then
                        break
                    fi
                    echo 请从新输入正确的版本号
                done
                case $area in
                全部)
                    case $version in
                    101*)
                        echo "请确认操作对 $area 体验区 $operate"
                        read
                        sed -i 's/101[0-9][0-9][0-9][0-9][0-9][0-9]/'$version'/' $conf
                    ;;
                    102*)
                        echo "请确认操作对 $area 正式区 $operate"
                        read
                        sed -i 's/102[0-9][0-9][0-9][0-9][0-9][0-9]/'$version'/' $conf
                    ;;
                    esac
                ;;
                *)
                    type=`awk -F '"' '/'$area'/{print $14}' $conf |cut -c1-3`
                    readtype=`echo $version |cut -c1-3`
                    if [ $type != $readtype ]
                    then
                        echo "版本号不对应，请从新操作"
                        continue
                    fi

                    echo "请确认操作对 $area 区 $operate"
                    read

                    awk -F '"' '/'$area'/{print $12}' $conf |xargs -i sed -i '/'{}'/s/10[12][0-9][0-9][0-9][0-9][0-9][0-9]/'$version'/' $conf
                ;;
                esac
            ;;
            添加维护中)
                case $area in
                全部)
                    echo "请确认操作对 $area 区 $operate"
                    read
                    awk -F '"' '/<s/{print $2}' $conf |xargs -i sed -i 's/'{}'/&维护中/' $conf
                ;;
                *)
                    echo "请确认操作对 $area 区 $operate"
                    read
                    sed -i 's/'$area'/&维护中/' $conf
                ;;
                esac
            ;;
            删除维护中)
                case $area in
                全部)
                    echo "请确认操作对 $area 区 $operate"
                    read
                    sed -i 's/维护中//' $conf
                ;;
                *)
                    echo "请确认操作对 $area 区 $operate"
                    read
                    sed -i '/'$area'/s/维护中//' $conf
                ;;
                esac
            ;;
            返回菜单)
                break
            ;;
            esac
        done
    ;;
    esac
    echo "回车重新选择区"
done

}
