all: copy

copy:
	sudo cp daily-todo.sh /bin/dtodo
	sudo chmod 755 /bin/dtodo

uninstall:
	sudo rm /bin/dtodo