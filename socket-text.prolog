% Server on localhost:1280 for GNU-prolog.
% Transfer hello string to web-client.

:- initialization( go ).

go :-
  socket( 'AF_INET', Sock ),
  socket_bind( Sock, 'AF_INET'(_, 1280) ),
  socket_listen( Sock, 10 ),
  loop( Sock ).

loop( Sock ):-
  repeat,
  socket_accept( Sock, Client, Sin, Sout ),
  format( "Client: ~a~n", [Client] ),

  get_text( Sin, Text ), writeq( Text ), nl,
  format( Sout, "HTTP/1.1 200 OK~nContent-Type: text/html; charset=utf-8~n~nПривет!", [] ),

  close( Sin ),
  close( Sout ),
  fail.
  
%-----------------------------------------------------------
get_text( S, [H | T] ):-
  get_line( S, H ),
  (H \= ['\r'] -> get_text( S, T ); T = []).

get_line( S, [] ):-
  peek_char( S, '\n' ), get_char( S, _ ), !.
get_line( S, [H | T] ):-
  get_word( S, H ), get_line( S, T ).

del_spaces( S ):-
  peek_char( S, ' ' )-> get_char( S, _ ), del_spaces( S ); true.

get_word( S, W ):-
  get_word_as_list( S, L ), atom_chars( W, L ).

get_word_as_list( S, [] ):-
  peek_char( S, ' ' ), del_spaces( S ), !.
get_word_as_list( S, [] ):-
  peek_char( S, '\n' ), !.
get_word_as_list( S, [H | T] ):-
  get_char( S, H ), get_word_as_list( S, T ).

