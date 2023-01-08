% Server on localhost:1280 for GNU-prolog.
% Transfer all jpg files from current directory
% to web-client in random order by refresh command of client.

:- initialization(go).

go :-
  socket( 'AF_INET',Sock ),
  socket_bind( Sock, 'AF_INET'(_, 1280) ),
  socket_listen( Sock, 10 ),
  loop( Sock ).

loop( Sock ):-
  repeat,
  directory_files( '.', L1 ),
  only_jpg( L1, L2 ), delete( L2, 0, L3 ),
  randomize, random_permutation( L3, L4 ),
  length( L4, N_pict ), N_pict_ is N_pict + 1,
  between( 1, N_pict_, I ),
  nth( I, L4, File),
  file_property( File, size( Size )),

  socket_accept( Sock, Client, Sin, Sout ),
  set_stream_type( Sout, binary ),

  format( "Client: ~a~n", [Client] ),
  get_text( Sin, Text ), writeq( Text ), nl,

  atom_codes( 'HTTP/1.1 200 OK\nContent-Type: image/jpeg\nContent-Length: ', List1 ),
  put_bytes( Sout, List1 ),

  number_codes( Size, List2 ),
  put_bytes( Sout, List2 ),
  atom_codes( '\nAccept-Ranges: bytes\n\n', List3 ),
  put_bytes( Sout, List3 ),

  open( File, read, S, [type(binary)] ),
    transport_bytes( S, Sout ),
  close( S ),

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

%--------------------------------------------------------------
put_bytes( _, [] ):- !.
put_bytes( Sout, [H | T] ):-
  put_byte( Sout, H ), put_bytes( Sout, T ).

transport_bytes( S_from, _ ):- at_end_of_stream( S_from ), !.
transport_bytes( S_from, S_to ):-
  get_byte( S_from, B ),
  put_byte( S_to, B ),
  transport_bytes( S_from, S_to ).

only_jpg( [], [] ).
only_jpg( [H1 | T1], [H2 | T2] ):-
  (decompose_file_name( H1, _, _, '.jpg' )-> H2 = H1; H2 = 0),
  only_jpg( T1, T2 ).

%-----------------------------------------------(
random_permutation( L1, L2 ):-
  list_to_random_vocab( L1, L1v ),
  keysort( L1v ),
  vocab_to_list( L1v, L2 ).

list_to_random_vocab( [], [] ).
list_to_random_vocab( [H1 | T1], [H2 | T2] ):-
  random( X ), H2 = X-H1,
  list_to_random_vocab( T1, T2 ).

vocab_to_list( [], [] ).
vocab_to_list( [_-V1 | T1], [V1 | T2] ):-
    vocab_to_list( T1, T2 ).
%-----------------------------------------------)

