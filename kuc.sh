#!/usr/bin/env bash
#kubectl use context

declare config_dir="$HOME/.kube/config.d"
declare current_file="$HOME/.kube/kuc_current"
declare local_bin="$HOME/.local/bin"
declare current_shell=$(ps -p $$ -o comm=)

install_self() {
	mkdir -p $local_bin
	self=$(readlink -f "$0")
	cp $self $local_bin/
	echo "Copied $self to $local_bin/$(basename $self)"
	sed -i '/^#kubectl use context/d' $HOME/.${current_shell}rc
	sed -i '/^kuc().*/d' $HOME/.${current_shell}rc
	echo "#kubectl use context
kuc() { source $local_bin/$(basename $self) \"\$@\"; }" >> $HOME/.${current_shell}rc
}

import() {
	local -a config_files=("$@")
	if [ "${#config_files[@]}" -eq 0 ]; then
		echo "Empty input. Exiting..."
		exit 1
	fi
	for config_file in ${config_files[@]}; do
		if ! [ -f "$config_file" ]; then
			echo "$config_file doesn't exist skipping..."
			continue
		else
			file_name=$(basename $config_file)
			cp $config_file $config_dir/$file_name
			chmod 600 $config_dir/$file_name
			echo "copied $config_file to $config_dir/$file_name"
		fi
	done
}

current() {
	if ! [ -f $current_file ]; then
		echo "No config is being used at the moment..."
	else
		local current=$(cat $current_file)
		echo "$current"
	fi
}

help() {
	echo "Kubectl Use Context Script"
	echo "Usage:
	./kuc.sh --help -> show this page
	./kuc.sh install -> copy the script to $local_bin
	kuc import [config files] -> copy the config files to $config_dir
	kuc current -> print the current config in use
	kuc -> select configs interactively
	kuc [number] -> select a specific config"
}

update_kubeconfig() {
	local context_to_use="$1"
	echo "Using config file $config_dir/$context_to_use.yaml"

	export KUBECONFIG="${config_dir}/${context_to_use}.yaml"

	sed -i '/^#kubectl context config file/d' $HOME/.bashrc
	sed -i '/^.*KUBECONFIG.*/d' $HOME/.bashrc

	echo "#kubectl context config file
export KUBECONFIG=${config_dir}/${context_to_use}.yaml" >> $HOME/.bashrc

	echo "$config_dir/$context_to_use.yaml" > $current_file
}

select_config() {
	local -a contexts=($(ls -tr $config_dir | sed 's/.yaml//'))
	if ! [ "$#" -eq 0 ] && [[ "$option" =~ ^([0-9]{1,3})$ ]] && [[ "$1" -gt 0 ]] && [[ "$1" -le ${#contexts[@]} ]]; then
		local option="$1"
	else
		echo "No args given or invalid arg. Going into interactive mode..."
		while true; do
			echo "Choose a context to use..."
			i=1
			for context in ${contexts[@]}; do
				echo "#$i -> $context"
				i=$(($i+1))
			done

			read -p "#? -> " option

			if [[ "$option" -gt 0 ]] && [[ "$option" =~ ^([0-9]{1,3})$ ]] && [[ "$option" -le ${#contexts[@]} ]]; then
				break
			else
				echo "Invalid input. Please enter numbers between 1 and ${#contexts[@]}..."
			fi
		done
	fi
	option=$(($option-1))
	local context_to_use="${contexts[$option]}"
	
	update_kubeconfig "$context_to_use"
}

kuc_main(){
	local option="$1" 
	shift

	if ! [ -d "$config_dir" ]; then
		echo "$config_dir doesn't exist yet, creating..."
		mkdir -m 750 -p $config_dir
	fi

	case $option in
		"--help")
			help
			;;
		"current")
			current
			;;
		"install")
			install_self
			;;
		"import")
			import "$@"
			;;
		[0-9]|[0-9][0-9]|[0-9][0-9][0-9]|"")
			select_config "$option"
			;;
		*)
			echo "Unknown option $option..."
			;;
	esac
}

kuc_main "$@"
