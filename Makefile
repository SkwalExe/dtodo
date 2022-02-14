all: copy

copy:
	sudo cp dtodo.sh /bin/dtodo
	sudo chmod 755 /bin/dtodo

uninstall:
	[ -f /bin/dtodo ] && sudo rm /bin/dtodo
