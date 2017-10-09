new Vue({
    el: '#app',

    data: {
        ws: null, // Our websocket
        newMsg: '', // Holds new messages to be sent to the server
        chatContent: '', // A running list of chat messages displayed on the screen
        username: null, // Our username
        joined: false, // True if username have been filled in
        receiver: null
    },

    created: function() {
        var self = this;
        this.ws = new WebSocket('ws://' + 'localhost:8000' + '/ws');
        this.ws.addEventListener('message', function(e) {
            var msg = JSON.parse(e.data);
            self.chatContent += '<div class="chip">'
                    + msg.username
                + '</div>'
                + emojione.toImage(msg.message) + '<br/>'; // Parse emojis

            var element = document.getElementById('chat-messages');
            element.scrollTop = element.scrollHeight; // Auto scroll to the bottom
        });
    },

    methods: {
        send: function () {
            if (this.newMsg != '') {
                this.ws.send(
                    JSON.stringify({
                        type: "Message",
                        data: {
                            username: this.username,
                            receiver: this.receiver,
                            message: $('<p>').html(this.newMsg).text() // Strip out html
                        }
                    }
                ));
                this.newMsg = ''; // Reset newMsg
            }
        },

        join: function () {
            if (!this.username) {
                Materialize.toast('You must choose a username', 2000);
                return
            }
            this.username = $('<p>').html(this.username).text();
            this.joined = true;
            this.ws.send(
                    JSON.stringify({
                        type: "JoinMessage",
                        data: {
                            username: this.username,
                        }
                    }
            ));
            Materialize.toast('Joined', 2000)
        },
    }
});