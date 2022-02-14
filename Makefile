all: copy

copy:
	sudo cp dtodo.sh /bin/dtodo
	sudo chmod 755 /bin/dtodo

uninstall:
	sudo rm /bin/dtodo
