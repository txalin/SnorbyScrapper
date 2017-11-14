#!/usr/bin/bash
#
# ------------------ SNORBY SCRAPPER 1.0 -----------------------
# DESCRIPTION: Bash script that connects to snorby frontend and 
# make searches 
#
# HOW TO USE IT: Add your username, password and hostname on
# snorby_username, snorby_password and snort_sensor, if you have
# more than one snorts, scroll down for instructions 
#
# Creator: Txalin
# Contact: txalin@gmail.com
# --------------------------------------------------------------

empty_src=0
empty_dst=0
empty_sig=0
payload_opt=f
tempDir=tmpSnorby

# SETUP YOUR SNORBY USERNAME AND PASSWORD, MUST BE THE SAME IN ALL SNORBYS
snorby_username=
snorby_password=
# ADD SNORBY FQDN
snort_sensor=

if [ ! -d "$tempDir" ]
then
	mkdir "$tempDir"
fi

if [ -z "$snorby_username" ]
then
	echo ""
	echo "And now tell me... How the hell am i suposse to log into snorby without a FUCKING USERNAME??? edit the damn script asshole!!"
	exit 1
fi

if [ -z "$snorby_password" ]
then
	echo ""
	echo "And now tell me... How the hell am i suposse to log into snorby without a FUCKING PASSWORD??? edit the damn script asshole!!"
	exit 1
fi

if [ -z "$snorby_password" ]
then
	echo ""
	echo "And now tell me... How the hell am i suposse to log into snorby without a FUCKING URL??? edit the damn script asshole!!"
	exit 1
fi

PS3='Please, select the fields that you want to search for: '
options=("Source IP" "Destination IP" "Signature" "Start date" "End date" "Payload options" "Group by" "Execute" "Exit")

#	SAMPLE OF OPTIONS ARRAY WITH SENSOR VARIABLE, USE IF YOU HAVE SEVERAL SNORBYS, COMMENT THE ONE ABOVE. REMEBER TO ENABLE THE COMMENTED SECTION IN THE CASE
#options=("Source IP" "Destination IP" "Signature" "Start date" "End date" "Payload options" "Group by" "Sensor" "Execute" "Exit")

select opt in "${options[@]}"
do
    case $opt in
        "Source IP")
			echo ""
            read -p "Source ip?: " src_ip
			if [ "$empty_src" -eq 0 ]
			then
				search=("${search[@]}" '"'${#search[@]}'":{"column":"source_ip","operator":"is","value":"'$src_ip'","enabled":true}')
				empty_src=1
				src_old_pos=${#search[@]}
			else 
				search[$src_old_pos-1]='"'$(expr $src_old_pos - 1)'":{"column":"source_ip","operator":"is","value":"'$src_ip'","enabled":true}'
			fi
			echo ""
            ;;
        "Destination IP")
			echo ""
            read -p "Destination ip?: " dst_ip
			if [ "$empty_dst" -eq 0 ]
			then
				search=("${search[@]}" '"'${#search[@]}'":{"column":"destination_ip","operator":"is","value":"'$dst_ip'","enabled":true}')
				empty_dst=1
				dst_old_pos=${#search[@]}
			else 
				search[$dst_old_pos-1]='"'$(expr $dst_old_pos - 1)'":{"column":"destination_ip","operator":"is","value":"'$dst_ip'","enabled":true}'
			fi
			echo ""
			;;
        "Signature")
			echo ""
            read -p "Signature?: " signature
			if [ "$empty_sig" -eq 0 ]
			then
				# MODIFICO LA FIRMA PARA ADECUARLA A LO QUE SNORBY ESPERA
				signature2=$(echo $signature | tr ' ' '+')
				search=("${search[@]}" '"'${#search[@]}'":{"column":"signature_name","operator":"contains","value":"'$signature2'","enabled":true}')
				empty_sig=1
				sig_old_pos=${#search[@]}
			else
				# MODIFICO LA FIRMA PARA ADECUARLA A LO QUE SNORBY ESPERA
				signature2=$(echo $signature | tr ' ' '+')
				search[$sig_old_pos-1]='"'$(expr $sig_old_pos - 1)'":{"column":"signature_name","operator":"contains","value":"'$signature2'","enabled":true}'
			fi
			echo ""
            ;;
		"Start date")
			echo ""
			read -p "Start date? (Format: YYYY MM DD hh mm ss ): " YYYY MM DD hh mm ss
			if date -d $year-$month-$day > /dev/null 2>&1; then
				start_date=$(date -d "$YYYY-$MM-$DD $hh:$mm:$ss" +%Y-%m-%d+%H:%M:%S)
			else
				echo "Invalid date"
			fi
			echo ""
			;;
		"End date")
			echo ""
			read -p "End date? (Format: YYYY MM DD hh mm ss ): " YYYY MM DD hh mm ss
			if date -d $year-$month-$day > /dev/null 2>&1; then
				end_date=$(date -d "$YYYY-$MM-$DD $hh:$mm:$ss" +%Y-%m-%d+%H:%M:%S)
			else
				echo "Invalid date"
			fi
			echo ""
			;;	
		"Payload options")
			if [ -n "$group_options" ]
			then
				echo ""
				echo "WARNING!! You cannot use payload mode with group by mode, deleting group_options"
				unset group_options
			fi
			
			echo ""
			read -p "Available options are: (a)scii,(h)exadecimal,(f)ull,(n)o payload: " payload_opt
			case $payload_opt in
				"a")
				payload_opt=a
				;;
				"h")
				payload_opt=h
				;;
				"f")
				payload_opt=f
				;;
				"n")
				payload_opt=n
				;;
				*)
				echo "Invalid option, try again"
				echo "Available options are: (a)scii,(h)exadecimal,(f)ull,(n)o payload"
				;;	
			esac
			echo ""
			;;
		#	USE THIS SECTION IF YOU HAVE MORE THAN ONE SNORBY INSTALLED
		#	
		#"Sensor")
		#	read -p "Available options are (d)mz,(c)ampus: " snort_sensor
		#	case $snort_sensor in
		#		"d")
		#		snort_sensor=snort_hostname.mycompany.com
		#		;;
		#		"c")
		#		snort_sensor=snort_hostname2.mycompany.com
		#		;;
		#		*)
		#		echo "Invalid option, try again"
		#		echo "Available options are (d)mz,(c)ampus: "
		#		;;
		#	esac
		#	;;
		"Group by")
			if [ -n "$payload_opt" ]
			then
				echo ""
				echo "WARNING!! You cannot use payload mode with group by mode, deleting group_options"
				unset payload_opt
			fi
			echo ""
			read -p "Available options are: (s)ource ip, (d)estination ip: " group_options
			case $group_options in
				"s")
				group_options=s
				;;
				"d")
				group_options=d
				;;
				*)
				echo "Invalid option, try again"
				echo "Available options are: (s)ource ip, (d)estination ip"
				;;
			esac
			echo ""
			;;
        "Execute")
			echo ""
			read -p "Are you sure? (y/n): " validate
			if [ $validate = "y" ]
			then 
								
				# SACAMOS LA FECHA INICIO Y LA FECHA FIN A BUSCAR EN SNORBY
				if [ -z "$start_date" ]
				then
					echo "no start date provided, try again"
					getinfo.snort.signature
				fi
				if [ -z "$end_date" ] 
				then
					echo "no end date provided, try again"
					getinfo.snort.signature
				fi
				
				search=("${search[@]}" '"'${#search[@]}'":{"column":"start_time","operator":"gte","value":"'$start_date'","enabled":true}')
				search=("${search[@]}" '"'${#search[@]}'":{"column":"end_time","operator":"lte","value":"'$end_date'","enabled":true}')
				search_string=$(echo "${search[@]}" | sed 's/:true} "/:true},"/g')
				#echo $search_string

				# NOS LOGUEAMOS EN SNORBY Y GUARDAMOS LAS SESIONES
				curl -i -s -k  -X 'GET' -H 'User-Agent: Mozilla/5.0 (Windows NT 6.1; WOW64; 42.0) Gecko/20100101 Firefox/42.0'     'http://'$snort_sensor'/users/login' | egrep '(_snorby_session=|input name="authenticity_token" type="hidden")' | sed -r 's/.+snorby_session=/snorby_session-..-/g' | sed -r 's/.+value="/auth_token-..-/g' | sed -r 's/".+//g' | sed -r 's/; .+//g' >> $tempDir/snorby_tokens.trash

				snorby_session=$(cat $tempDir/snorby_tokens.trash | grep snorby_session | awk -F '-..-' '{print $2}')
				auth_token=$(cat $tempDir/snorby_tokens.trash | grep auth_token | awk -F '-..-' '{print $2}')

				curl -i -s -k  -X 'POST' -H 'User-Agent: Mozilla/5.0 (Windows NT 6.1; WOW64; rv:42.0) Gecko/20100101 Firefox/42.0' -H 'X-CSRF-Token: '$auth_token'' -H 'Content-Type: application/x-www-form-urlencoded; charset=UTF-8' -H 'X-Requested-With: XMLHttpRequest' -H 'Referer: http://'$snort_sensor'/users/login' -b '_snorby_session='$snorby_session'' --data-binary $'utf8=%E2%9C%93&authenticity_token='$auth_token'&user%5Bemail%5D='$snorby_username'&user%5Bpassword%5D='$snorby_password'&user%5Bremember_me%5D=0&user%5Bremember_me%5D=1' 'http://'$snort_sensor'/users/login' | grep  remember_user_token= | sed -r 's/; .+//g' | sed 's/Set-Cookie: remember_user_token=/remember_user_token-..-/g' >> $tempDir/snorby_tokens.trash

				remember_user_token=$(cat $tempDir/snorby_tokens.trash | grep remember_user_token | awk -F '-..-' '{print $2}')

				# REALIZAMOS LA BUSQUEDA Y SACAMOS EL NUMERO DE PÁGINAS QUE NOS HA DEVUELTO
				
				curl -i -s -k  -X 'POST'     -H 'User-Agent: Mozilla/5.0 (Windows NT 6.1; WOW64; rv:42.0) Gecko/20100101 Firefox/42.0' -H 'Referer: http://'$snort_sensor'/search' -H 'Content-Type: application/x-www-form-urlencoded'     -b '_snorby_session='$snorby_session'; remember_user_token='$remember_user_token''     --data-binary $'match_all=true&search={'$search_string'}&authenticity_token='$auth_token''     'http://'$snort_sensor'/results' >> $tempDir/snort_contador.trash
				if [ $( cat $tempDir/snort_contador.trash | grep 'last jump' | awk -F 'page=' '{print $2}' | awk -F '"' '{print $1}') ]
				then
					contador=$( cat $tempDir/snort_contador.trash | grep 'last jump' | awk -F 'page=' '{print $2}' | awk -F '"' '{print $1}')
				else
					contador=1
				fi
								
				
				# GUARDAMOS LOS RESULTADOS EN FICHERO, SI HAY MAS DE 5 PAGINAS DE RESULTADOS CONSULTAMOS AL USUARIO SI QUIERE VER MENOS RESULTADOS (100 LINEAS POR PÁGINA)
				
				if [ $contador -gt 5 ]
				then
					echo "----------------------------------------------------------------------------------------------------------------------------------------"
					echo ""
					echo "WARNING!! ACHTUNG!! OJOCUIDAO!! Number of pages found: $contador , 100 events on each page"
					read -p "Do you want to modify the number of pages to be shown? (y/n): "  validate
					echo ""
					if [ $validate = "y" ]
					then 
						read -p "Insert the amount of pages to be shown (less than $contador): " contador_tmp
						while [ $contador_tmp -gt $contador ]
						do 
							read -p "Amount of pages is only $contador, try again ( value less than $contador): " contador_tmp; 
						done
						contador=$contador_tmp
						for i in $(seq 1 $contador)
						do
							echo "Getting events from page $i"
							curl -i -s -k  -X 'POST'     -H 'User-Agent: Mozilla/5.0 (Windows NT 6.1; WOW64; rv:42.0) Gecko/20100101 Firefox/42.0' -H 'Referer: http://'$snort_sensor'/search' -H 'Content-Type: application/x-www-form-urlencoded'     -b '_snorby_session='$snorby_session'; remember_user_token='$remember_user_token''     --data-binary $'match_all=true&search={'$search_string'}&authenticity_token='$auth_token''     'http://'$snort_sensor'/results?page='$i'' | egrep '(click src_ip address|click dst_ip address|<span title=|Event ID:)' | sed 's/\t//g' | sed -r 's/ .+<b/<b/g' | sed -r 's/ .+<div/<div/g' | tr '\n' ' ' | sed 's/<\/b>/\n/g' | sed 's/ <div/<div/g' | sed "s/'//g" | sed 's/"//g' | sed -r 's/class=.+div data-address=/-..-/g' | sed 's/ class=click dst_ip address>         <span title=/-..-/g' | sed 's/> <b title=Event ID: /-..-/g' | sed 's/ &nbsp; /-..-/g' | sed -r 's/ class=add_tipsy>.+//g' | sed 's/<div data-address=//g' >> $tempDir/snort_alerts.trash
						done
					else
						for i in $(seq 1 $contador)
						do
							echo "Getting events from page $i"
							curl -i -s -k  -X 'POST'     -H 'User-Agent: Mozilla/5.0 (Windows NT 6.1; WOW64; rv:42.0) Gecko/20100101 Firefox/42.0' -H 'Referer: http://'$snort_sensor'/search' -H 'Content-Type: application/x-www-form-urlencoded'     -b '_snorby_session='$snorby_session'; remember_user_token='$remember_user_token''     --data-binary $'match_all=true&search={'$search_string'}&authenticity_token='$auth_token''     'http://'$snort_sensor'/results?page='$i'' | egrep '(click src_ip address|click dst_ip address|<span title=|Event ID:)' | sed 's/\t//g' | sed -r 's/ .+<b/<b/g' | sed -r 's/ .+<div/<div/g' | tr '\n' ' ' | sed 's/<\/b>/\n/g' | sed 's/ <div/<div/g' | sed "s/'//g" | sed 's/"//g' | sed -r 's/class=.+div data-address=/-..-/g' | sed 's/ class=click dst_ip address>         <span title=/-..-/g' | sed 's/> <b title=Event ID: /-..-/g' | sed 's/ &nbsp; /-..-/g' | sed -r 's/ class=add_tipsy>.+//g' | sed 's/<div data-address=//g' >> $tempDir/snort_alerts.trash
						done
					fi
				else
					for i in $(seq 1 $contador)
					do
						echo "Getting events from page $i"
						curl -i -s -k  -X 'POST'     -H 'User-Agent: Mozilla/5.0 (Windows NT 6.1; WOW64; rv:42.0) Gecko/20100101 Firefox/42.0' -H 'Referer: http://'$snort_sensor'/search' -H 'Content-Type: application/x-www-form-urlencoded'     -b '_snorby_session='$snorby_session'; remember_user_token='$remember_user_token''     --data-binary $'match_all=true&search={'$search_string'}&authenticity_token='$auth_token''     'http://'$snort_sensor'/results?page='$i'' | egrep '(click src_ip address|click dst_ip address|<span title=|Event ID:)' | sed 's/\t//g' | sed -r 's/ .+<b/<b/g' | sed -r 's/ .+<div/<div/g' | tr '\n' ' ' | sed 's/<\/b>/\n/g' | sed 's/ <div/<div/g' | sed "s/'//g" | sed 's/"//g' | sed -r 's/class=.+div data-address=/-..-/g' | sed 's/ class=click dst_ip address>         <span title=/-..-/g' | sed 's/> <b title=Event ID: /-..-/g' | sed 's/ &nbsp; /-..-/g' | sed -r 's/ class=add_tipsy>.+//g' | sed 's/<div data-address=//g' >> $tempDir/snort_alerts.trash
					done
				fi
				
				echo "----------------------------------------------------------------------------------------------------------------------------------------"
		
				# SACAMOS PAYLOAD POR PANTALLA SI NO HAY GROUP BY
				if [ -z $group_options ]
				then
					# SI HAY OPCION DE PAYLOAD CONFIGURADA LO MOSTRAMOS
					if [ $payload_opt != n ]
					then 
						while read linea; 
						do 
						id1=$(echo $linea | awk -F '-..-' '{print $4}' | awk -F '.' '{print $1}')
						id2=$(echo $linea | awk -F '-..-' '{print $4}'  | awk -F '.' '{print $2}')
						tmpsources=$(echo $linea | awk -F '-..-' '{print $1" --> "$2}')
						signature=$(echo $linea | awk -F '-..-' '{print $3}')
						date=$(echo $linea | awk -F '-..-' '{print $5}')
						echo $date" ||  "$tmpsources" || "$signature
						echo "----------------------------------------------------------------------------------------------------------------------------------------"
						
						if [ $payload_opt == a ]
						then
							curl -i -s -k  -X 'GET'     -H 'User-Agent: Mozilla/5.0 (Windows NT 6.1; WOW64; rv:42.0) Gecko/20100101 Firefox/42.0' -H 'X-CSRF-Token: '$auth_token'' -H 'Content-Type: application/x-www-form-urlencoded' -H 'X-Requested-With: XMLHttpRequest' -H 'Referer: http://'$snort_sensor'/results' -b '_snorby_session='$snorby_session'; remember_user_token='$remember_user_token''     'http://'$snort_sensor'/events/show/'$id1'/'$id2'?_=1447259042884' | grep -a -i payload-number | sed -r "s/.+<div class='payload plus-side payload-holder'><pre><span class='payload-number'/<span class='payload-number'/g" | sed -r "s/.+payload-ascii'>|<\/span>//g" | tr '\n' ' '
						elif [ $payload_opt == h ]
						then 
							curl -i -s -k  -X 'GET'     -H 'User-Agent: Mozilla/5.0 (Windows NT 6.1; WOW64; rv:42.0) Gecko/20100101 Firefox/42.0' -H 'X-CSRF-Token: '$auth_token'' -H 'Content-Type: application/x-www-form-urlencoded' -H 'X-Requested-With: XMLHttpRequest' -H 'Referer: http://'$snort_sensor'/results' -b '_snorby_session='$snorby_session'; remember_user_token='$remember_user_token''     'http://'$snort_sensor'/events/show/'$id1'/'$id2'?_=1447259042884' |  grep -a -i payload-number | sed -r "s/.+<div class='payload plus-side payload-holder'><pre><span class='payload-number'/<span class='payload-number'/g" |  awk -F "'>" '{print $2,$3}' | sed "s/<\/span> <span class='payload-hex//g" | sed "s/<\/span> <span class='payload-ascii//g"
						elif [ $payload_opt == f ]
						then
							curl -i -s -k  -X 'GET'     -H 'User-Agent: Mozilla/5.0 (Windows NT 6.1; WOW64; rv:42.0) Gecko/20100101 Firefox/42.0' -H 'X-CSRF-Token: '$auth_token'' -H 'Content-Type: application/x-www-form-urlencoded' -H 'X-Requested-With: XMLHttpRequest' -H 'Referer: http://'$snort_sensor'/results' -b '_snorby_session='$snorby_session'; remember_user_token='$remember_user_token''     'http://'$snort_sensor'/events/show/'$id1'/'$id2'?_=1447259042884' | grep -a -i payload-number | sed "s/<span class='payload-number'>//g" | sed "s/<\/span>//g" | sed "s/<span class='payload-hex'>//g" | sed "s/<span class='payload-ascii'>//g" | sed -r "s/.+<div class='payload plus-side payload-holder'><pre>//g"
						fi
						
						echo
						echo
						echo "----------------------------------------------------------------------------------------------------------------------------------------"		
						done < $tempDir/snort_alerts.trash
					else 
						cat $tempDir/snort_alerts.trash | grep CEST | awk -F '-..-' '{print $5 " || " $1 " --> " $2 " || " $3}'
					fi
						
				elif [ $group_options = s ]
				then
					cat $tempDir/snort_alerts.trash | awk -F '-..-' '{print $1 " --> " $2 " : "$3}' | egrep [0-9] | sort -n | uniq -c | sort -rn
				elif [ $group_options = d ]
				then
					cat $tempDir/snort_alerts.trash | awk -F '-..-' '{print $2 " <-- " $1 " : "$3}' | egrep [0-9] | sort -n | uniq -c | sort -rn
				fi
				
				echo "-------------------------------- DEBUG -----------------------------------"
				echo "sensor:" $snort_sensor
				echo "snorby_session: "$snorby_session
				echo "auth_token: "$auth_token
				echo "remember_user_token: "$remember_user_token
				echo "start_date: "$start_date
				echo "end_date: "$end_date
				echo "signature: "$signature
				echo "------------------------------- /DEBUG -----------------------------------"

				# HACEMOS LOGOUT PARA NO TOSTAR EL SNORBY
				curl -i -s -k  -X 'GET'     -H 'User-Agent: Mozilla/5.0 (Windows NT 6.1; WOW64; rv:42.0) Gecko/20100101 Firefox/42.0' -H 'Referer: http://'$snort_sensor'/results'     -b '_snorby_session='$snorby_session'; remember_user_token='$remember_user_token''     'http://'$snort_sensor'/users/logout' >>  $tempDir/trash.trash	
				
				rm $tempDir/*.trash
				unset search
				unset start_date
				unset end_date
				empty_src=0
				empty_dst=0
				empty_sig=0
			fi
         ;;
		"Exit")	
			exit 1
		;;
        *) echo Invalid option, try again;;
    esac
done
