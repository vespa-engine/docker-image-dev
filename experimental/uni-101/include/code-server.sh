set -euxo pipefail

# echo "Installing code-server..."
# curl -fsSL https://code-server.dev/install.sh | sh

echo "Creating init.d for code-server..."
cat << 'EOF' > /etc/init.d/code-server
#!/bin/sh
### BEGIN INIT INFO
# Provides:          code-server
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: code-server service for browser-based VS Code
# Description:       Starts code-server to allow VS Code access via a web browser.
### END INIT INFO

PATH=/sbin:/usr/sbin:/bin:/usr/bin
DESC="code-server"
NAME=code-server
DAEMON=/usr/bin/code-server
USER=student
OPTS="--host 0.0.0.0 --port 5000 --auth none /home/student/lab/"
PIDFILE=/var/run/$NAME.pid

. /lib/lsb/init-functions

do_start() {
    log_daemon_msg "Starting $DESC" "$NAME"
    # this is needed for the vespa-language-server to work
    start-stop-daemon --start --quiet --background --chuid $USER --make-pidfile --pidfile $PIDFILE --exec $DAEMON -- $OPTS
    status=$?
    if [ $status -eq 0 ]; then
        log_end_msg 0
    else
        log_end_msg 1
    fi
    return $status
}

do_stop() {
    log_daemon_msg "Stopping $DESC" "$NAME"
    start-stop-daemon --stop --quiet --pidfile $PIDFILE
    status=$?
    if [ $status -eq 0 ]; then
        log_end_msg 0
    else
        log_end_msg 1
    fi
    rm -f $PIDFILE
    return $status
}

case "$1" in
    start)
        do_start
        ;;
    stop)
        do_stop
        ;;
    restart)
        do_stop
        do_start
        ;;
    status)
        if [ -f "$PIDFILE" ]; then
            PID=$(cat "$PIDFILE")
            if kill -0 "$PID" > /dev/null 2>&1; then
                echo "$NAME is running (pid $PID)"
                exit 0
            else
                echo "$NAME is not running, but pid file exists"
                exit 1
            fi
        else
            echo "$NAME is not running"
            exit 3
        fi
        ;;
    *)
        echo "Usage: /etc/init.d/$NAME {start|stop|restart|status}"
        exit 1
        ;;
esac

exit 0
EOF

chmod +x /etc/init.d/code-server
