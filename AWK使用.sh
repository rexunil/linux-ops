 awk{

        # 默认是执行打印全部 print $0
        # 1为真 打印$0
        # 0为假 不打印

        -F   # 改变FS值(分隔符)
        ~    # 域匹配
        ==   # 变量匹配
        !~   # 匹配不包含
        =    # 赋值
        !=   # 不等于
        +=   # 叠加

        \b   # 退格
        \f   # 换页
        \n   # 换行
        \r   # 回车
        \t   # 制表符Tab
        \c   # 代表任一其他字符

        -F"[ ]+|[%]+"  # 多个空格或多个%为分隔符
        [a-z]+         # 多个小写字母
        [a-Z]          # 代表所有大小写字母(aAbB...zZ)
        [a-z]          # 代表所有大小写字母(ab...z)
        [:alnum:]      # 字母数字字符
        [:alpha:]      # 字母字符
        [:cntrl:]      # 控制字符
        [:digit:]      # 数字字符
        [:graph:]      # 非空白字符(非空格、控制字符等)
        [:lower:]      # 小写字母
        [:print:]      # 与[:graph:]相似，但是包含空格字符
        [:punct:]      # 标点字符
        [:space:]      # 所有的空白字符(换行符、空格、制表符)
        [:upper:]      # 大写字母
        [:xdigit:]     # 十六进制的数字(0-9a-fA-F)
        [[:digit:][:lower:]]    # 数字和小写字母(占一个字符)


        内建变量{
            $n            # 当前记录的第 n 个字段，字段间由 FS 分隔
            $0            # 完整的输入记录
            ARGC          # 命令行参数的数目
            ARGIND        # 命令行中当前文件的位置 ( 从 0 开始算 )
            ARGV          # 包含命令行参数的数组
            CONVFMT       # 数字转换格式 ( 默认值为 %.6g)
            ENVIRON       # 环境变量关联数组
            ERRNO         # 最后一个系统错误的描述
            FIELDWIDTHS   # 字段宽度列表 ( 用空格键分隔 )
            FILENAME      # 当前文件名
            FNR           # 同 NR ，但相对于当前文件
            FS            # 字段分隔符 ( 默认是任何空格 )
            IGNORECASE    # 如果为真（即非 0 值），则进行忽略大小写的匹配
            NF            # 当前记录中的字段数(列)
            NR            # 当前行数
            OFMT          # 数字的输出格式 ( 默认值是 %.6g)
            OFS           # 输出字段分隔符 ( 默认值是一个空格 )
            ORS           # 输出记录分隔符 ( 默认值是一个换行符 )
            RLENGTH       # 由 match 函数所匹配的字符串的长度
            RS            # 记录分隔符 ( 默认是一个换行符 )
            RSTART        # 由 match 函数所匹配的字符串的第一个位置
            SUBSEP        # 数组下标分隔符 ( 默认值是 /034)
            BEGIN         # 先处理(可不加文件参数)
            END           # 结束时处理
        }

        内置函数{
            gsub(r,s)          # 在整个$0中用s替代r   相当于 sed 's///g'
            gsub(r,s,t)        # 在整个t中用s替代r
            index(s,t)         # 返回s中字符串t的第一位置
            length(s)          # 返回s长度
            match(s,r)         # 测试s是否包含匹配r的字符串
            split(s,a,fs)      # 在fs上将s分成序列a
            sprint(fmt,exp)    # 返回经fmt格式化后的exp
            sub(r,s)           # 用$0中最左边最长的子串代替s   相当于 sed 's///'
            substr(s,p)        # 返回字符串s中从p开始的后缀部分
            substr(s,p,n)      # 返回字符串s中从p开始长度为n的后缀部分
        }

        awk判断{
            awk '{print ($1>$2)?"第一排"$1:"第二排"$2}'      # 条件判断 括号代表if语句判断 "?"代表then ":"代表else
            awk '{max=($1>$2)? $1 : $2; print max}'          # 条件判断 如果$1大于$2,max值为为$1,否则为$2
            awk '{if ( $6 > 50) print $1 " Too high" ;\
            else print "Range is OK"}' file
            awk '{if ( $6 > 50) { count++;print $3 } \
            else { x+5; print $2 } }' file
        }

        awk循环{
            awk '{i = 1; while ( i <= NF ) { print NF, $i ; i++ } }' file
            awk '{ for ( i = 1; i <= NF; i++ ) print NF,$i }' file
        }

        awk '/Tom/' file               # 打印匹配到得行
        awk '/^Tom/{print $1}'         # 匹配Tom开头的行 打印第一个字段
        awk '$1 !~ /ly$/'              # 显示所有第一个字段不是以ly结尾的行
        awk '$3 <40'                   # 如果第三个字段值小于40才打印
        awk '$4==90{print $5}'         # 取出第四列等于90的第五列
        awk '/^(no|so)/' test          # 打印所有以模式no或so开头的行
        awk '$3 * $4 > 500'            # 算术运算(第三个字段和第四个字段乘积大于500则显示)
        awk '{print NR" "$0}'          # 加行号
        awk '/tom/,/suz/'              # 打印tom到suz之间的行
        awk '{a+=$1}END{print a}'      # 列求和
        awk 'sum+=$1{print sum}'       # 将$1的值叠加后赋给sum
        awk '{a+=$1}END{print a/NR}'   # 列求平均值
        awk '!s[$1 $3]++' file         # 根据第一列和第三列过滤重复行
        awk -F'[ :\t]' '{print $1,$2}'           # 以空格、:、制表符Tab为分隔符
        awk '{print "'"$a"'","'"$b"'"}'          # 引用外部变量
        awk '{if(NR==52){print;exit}}'           # 显示第52行
        awk '/关键字/{a=NR+2}a==NR {print}'      # 取关键字下第几行
        awk 'gsub(/liu/,"aaaa",$1){print $0}'    # 只打印匹配替换后的行
        ll | awk -F'[ ]+|[ ][ ]+' '/^$/{print $8}'             # 提取时间,空格不固定
        awk '{$1="";$2="";$3="";print}'                        # 去掉前三列
        echo aada:aba|awk '/d/||/b/{print}'                    # 匹配两内容之一
        echo aada:abaa|awk -F: '$1~/d/||$2~/b/{print}'         # 关键列匹配两内容之一
        echo Ma asdas|awk '$1~/^[a-Z][a-Z]$/{print }'          # 第一个域匹配正则
        echo aada:aaba|awk '/d/&&/b/{print}'                   # 同时匹配两条件
        awk 'length($1)=="4"{print $1}'                        # 字符串位数
        awk '{if($2>3){system ("touch "$1)}}'                  # 执行系统命令
        awk '{sub(/Mac/,"Macintosh",$0);print}'                # 用Macintosh替换Mac
        awk '{gsub(/Mac/,"MacIntosh",$1); print}'              # 第一个域内用Macintosh替换Mac
        awk -F '' '{ for(i=1;i<NF+1;i++)a+=$i  ;print a}'      # 多位数算出其每位数的总和.比如 1234， 得到 10
        awk '{ i=$1%10;if ( i == 0 ) {print i}}'               # 判断$1是否整除(awk中定义变量引用时不能带 $ )
        awk 'BEGIN{a=0}{if ($1>a) a=$1 fi}END{print a}'        # 列求最大值  设定一个变量开始为0，遇到比该数大的值，就赋值给该变量，直到结束
        awk 'BEGIN{a=11111}{if ($1<a) a=$1 fi}END{print a}'    # 求最小值
        awk '{if(A)print;A=0}/regexp/{A=1}'                    # 查找字符串并将匹配行的下一行显示出来，但并不显示匹配行
        awk '/regexp/{print A}{A=$0}'                          # 查找字符串并将匹配行的上一行显示出来，但并不显示匹配行
        awk '{if(!/mysql/)gsub(/1/,"a");print $0}'             # 将1替换成a，并且只在行中未出现字串mysql的情况下替换
        awk 'BEGIN{srand();fr=int(100*rand());print fr;}'      # 获取随机数
        awk '{if(NR==3)F=1}{if(F){i++;if(i%7==1)print}}'       # 从第3行开始，每7行显示一次
        awk '{if(NF<1){print i;i=0} else {i++;print $0}}'      # 显示空行分割各段的行数
        echo +null:null  |awk -F: '$1!~"^+"&&$2!="null"{print $0}'       # 关键列同时匹配
        awk -v RS=@ 'NF{for(i=1;i<=NF;i++)if($i) printf $i;print ""}'    # 指定记录分隔符
        awk '{b[$1]=b[$1]$2}END{for(i in b){print i,b[i]}}'              # 列叠加
        awk '{ i=($1%100);if ( $i >= 0 ) {print $0,$i}}'                 # 求余数
        awk '{b=a;a=$1; if(NR>1){print a-b}}'                            # 当前行减上一行
        awk '{a[NR]=$1}END{for (i=1;i<=NR;i++){print a[i]-a[i-1]}}'      # 当前行减上一行
        awk -F: '{name[x++]=$1};END{for(i=0;i<NR;i++)print i,name[i]}'   # END只打印最后的结果,END块里面处理数组内容
        awk '{sum2+=$2;count=count+1}END{print sum2,sum2/count}'         # $2的总和  $2总和除个数(平均值)
        awk -v a=0 -F 'B' '{for (i=1;i<NF;i++){ a=a+length($i)+1;print a  }}'     # 打印所以B的所在位置
        awk 'BEGIN{ "date" | getline d; split(d,mon) ; print mon[2]}' file        # 将date值赋给d，并将d设置为数组mon，打印mon数组中第2个元素
        awk 'BEGIN{info="this is a test2010test!";print substr(info,4,10);}'      # 截取字符串(substr使用)
        awk 'BEGIN{info="this is a test2010test!";print index(info,"test")?"ok":"no found";}'      # 匹配字符串(index使用)
        awk 'BEGIN{info="this is a test2010test!";print match(info,/[0-9]+/)?"ok":"no found";}'    # 正则表达式匹配查找(match使用)
        awk '{for(i=1;i<=4;i++)printf $i""FS; for(y=10;y<=13;y++)  printf $y""FS;print ""}'        # 打印前4列和后4列
        awk 'BEGIN{for(n=0;n++<9;){for(i=0;i++<n;)printf i"x"n"="i*n" ";print ""}}'                # 乘法口诀
        awk 'BEGIN{info="this is a test";split(info,tA," ");print length(tA);for(k in tA){print k,tA[k];}}'             # 字符串分割(split使用)
        awk '{if (system ("grep "$2" tmp/* > /dev/null 2>&1") == 0 ) {print $1,"Y"} else {print $1,"N"} }' a            # 执行系统命令判断返回状态
        awk  '{for(i=1;i<=NF;i++) a[i,NR]=$i}END{for(i=1;i<=NF;i++) {for(j=1;j<=NR;j++) printf a[i,j] " ";print ""}}'   # 将多行转多列
        netstat -an|awk -v A=$IP -v B=$PORT 'BEGIN{print "Clients\tGuest_ip"}$4~A":"B{split($5,ip,":");a[ip[1]]++}END{for(i in a)print a[i]"\t"i|"sort -nr"}'    # 统计IP连接个数
        cat 1.txt|awk -F" # " '{print "insert into user (user,password,email)values(""'\''"$1"'\'\,'""'\''"$2"'\'\,'""'\''"$3"'\'\)\;'"}' >>insert_1.txt     # 处理sql语句
        awk 'BEGIN{printf "what is your name?";getline name < "/dev/tty" } $1 ~name {print "FOUND" name " on line ", NR "."} END{print "see you," name "."}' file  # 两文件匹配

        取本机IP{
            /sbin/ifconfig |awk -v RS="Bcast:" '{print $NF}'|awk -F: '/addr/{print $2}'
            /sbin/ifconfig |awk '/inet/&&$2!~"127.0.0.1"{split($2,a,":");print a[2]}'
            /sbin/ifconfig |awk -v RS='inet addr:' '$1!="eth0"&&$1!="127.0.0.1"{print $1}'|awk '{printf"%s|",$0}'
            /sbin/ifconfig |awk  '{printf("line %d,%s\n",NR,$0)}'         # 指定类型(%d数字,%s字符)
        }

        查看磁盘空间{
            df -h|awk -F"[ ]+|%" '$5>14{print $5}'
            df -h|awk 'NR!=1{if ( NF == 6 ) {print $5} else if ( NF == 5) {print $4} }'
            df -h|awk 'NR!=1 && /%/{sub(/%/,"");print $(NF-1)}'
            df -h|sed '1d;/ /!N;s/\n//;s/ \+/ /;'    #将磁盘分区整理成一行   可直接用 df -P
        }

        排列打印{
            awk 'END{printf "%-10s%-10s\n%-10s%-10s\n%-10s%-10s\n","server","name","123","12345","234","1234"}' txt
            awk 'BEGIN{printf "|%-10s|%-10s|\n|%-10s|%-10s|\n|%-10s|%-10s|\n","server","name","123","12345","234","1234"}'
            awk 'BEGIN{
            print "   *** 开 始 ***   ";
            print "+-----------------+";
            printf "|%-5s|%-5s|%-5s|\n","id","name","ip";
            }
            $1!=1 && NF==4{printf "|%-5s|%-5s|%-5s|\n",$1,$2,$3" "$11}
            END{
            print "+-----------------+";
            print "   *** 结 束 ***   "
            }' txt
        }

        老男孩awk经典题{
            分析图片服务日志，把日志（每个图片访问次数*图片大小的总和）排行，也就是计算每个url的总访问大小
            说明：本题生产环境应用：这个功能可以用于IDC网站流量带宽很高，然后通过分析服务器日志哪些元素占用流量过大，进而进行优化或裁剪该图片，压缩js等措施。
            本题需要输出三个指标： 【被访问次数】    【访问次数*单个被访问文件大小】   【文件名（带URL）】
            测试数据
            59.33.26.105 - - [08/Dec/2010:15:43:56 +0800] "GET /static/images/photos/2.jpg HTTP/1.1" 200 11299

            awk '{array_num[$7]++;array_size[$7]+=$10}END{for(i in array_num) {print array_num[i]" "array_size[i]" "i}}'
        }

        awk练习题{

            wang     4
            cui      3
            zhao     4
            liu      3
            liu      3
            chang    5
            li       2

            1 通过第一个域找出字符长度为4的
            2 当第二列值大于3时，创建空白文件，文件名为当前行第一个域$1 (touch $1)
            3 将文档中 liu 字符串替换为 hong
            4 求第二列的和
            5 求第二列的平均值
            6 求第二列中的最大值
            7 将第一列过滤重复后，列出每一项，每一项的出现次数，每一项的大小总和

            1、字符串长度
                awk 'length($1)=="4"{print $1}'
            2、执行系统命令
                awk '{if($2>3){system ("touch "$1)}}'
            3、gsub(/r/,"s",域) 在指定域(默认$0)中用s替代r  (sed 's///g')
                awk '{gsub(/liu/,"hong",$1);print $0}' a.txt
            4、列求和
                awk '{a+=$2}END{print a}'
            5、列求平均值
                awk '{a+=$2}END{print a/NR}'
                awk '{a+=$2;b++}END{print a,a/b}'
            6、列求最大值
                awk 'BEGIN{a=0}{if($2>a) a=$2 }END{print a}'
            7、将第一列过滤重复列出每一项，每一项的出现次数，每一项的大小总和
                awk '{a[$1]++;b[$1]+=$2}END{for(i in a){print i,a[i],b[i]}}'
        }

        awk处理复杂日志{
            6.19：
            DHB_014_号百总机服务业务日报：广州 到达数异常！
            DHB_023_号百漏话提醒日报：珠海 到达数异常！
            6.20：
            DHB_014_号百总机服务业务日报：广州 到达数异常！到

            awk -F '[_ ：]+' 'NF>2{print $4,$1"_"$2,b |"sort";next}{b=$1}'

            # 当前行NF小于等于2 只针对{print $4,$1"_"$2,b |"sort";next} 有效 即 6.19：行跳过此操作,  {b=$1} 仍然执行
            # 当前行NF大于2 执行到 next 强制跳过本行，即跳过后面的 {b=$1}

            广州 DHB_014 6.19
        }
    }
