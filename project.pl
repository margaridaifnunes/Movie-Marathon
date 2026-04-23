:- encoding(utf8).
% Margarida Nunes, ist1117809
:- style_check(-discontiguous).
:- set_prolog_flag(answer_write_options,[max_depth(0)]).
:- ['codigoAuxiliar.pl'].
:- ['bd_estudantes.pl'].
:- ['listas_palavras.pl'].
 
% PARTE 1 % 
/* media/2 - calcula a média arredondada a 2 casas decimais de determinados valores;
             é verdade se Media corresponder ao valor calculado */
media([], 0) :- !.                          % se a lista tiver 0 elementos
media(ListaValores, Media) :-               % se a lista tiver 1 ou mais elementos
    ListaValores \= [],                     % verificar que não é a lista vazia
    sum_list(ListaValores, Soma),           % somar todos os valores da lista
    length(ListaValores, Comprimento),      % contar o número de elementos
    Media is round((Soma / Comprimento)*100) / 100.

/* mediaNotasPorIdade/3 - calcula a média das notas de estudantes de certa idade;
                          é verdade se Media corresponder ao valor calculado */
mediaNotasPorIdade(IdadeMin,IdadeMax, Media) :-
    findall(NotaExame,
        (estudante(Id,Idade,_), % selecionar estudantes
        Idade > IdadeMin,       % filtrar alunos pelas idades
        Idade =< IdadeMax,      
        exame(Id,NotaExame)),   % ir buscar a NotaExame dos alunos
        Lista),                 % acrescentar NotaExame à lista, se for uma aluno filtrado
    media(Lista,Media).

/* freqPorGenero/2 - calcula a média de frequencia de estudantes de certo género;
                     é verdade se MediaFreq corresponder ao valor calculado  */
freqPorGenero(Genero, MediaFreq) :-
    findall(FrequenciaAulas,
        (estudante(Id,_,Genero_al),         % selecionar estudantes                   
        Genero_al == Genero,                % filtrar consoante o género
        atividade(Id,_,_,FrequenciaAulas)), % ir buscar a FrequenciaAulas dos alunos
        Lista),                             % adicionar à lista as FrequenciaAulas
    media(Lista,MediaFreq).

/* alertaSaude/4 - resulta numa lista com os Id's dos estudantes verificam as
                   seguintes condições: fraca qualidade de alimentação; horas de
                   sono, execício e saúde mental abaixo do valor referência;
                   é verdade se a ListAluno for a lista obtida no final */
alertaSaude(HorasSono, Exercicio, SaudeMental, ListAlunos) :-
    findall(Id,
    (saude(Id,HorasSono_al,QualidadeAlimentacao_al,Exercicio_al, SaudeMental_al),
    QualidadeAlimentacao_al == fraca,   % filtrar por QualidadeAlimentação fraca
    HorasSono_al < HorasSono,           % filtrar por poucas HorasSono
    Exercicio_al < Exercicio,           % filtrar quem faz menos exercício que Exercicio
    SaudeMental_al < SaudeMental),      % filtrar quem tem SaudeMental em baixo
    ListAlunos).                        % acrescentar os Id's dos selecionados a uma lista

/* probEcraNotasAltas/3 - considerando as horas de ecrã de um estudantes, avalia a
                          avalia a probabilidade de tirar notas elevadas. Para tal,
                          dividi o problema em 4 etapas: determinar quantos alunos tem 
                          mais horas de Ecra que a referência, determinar quem tira notas
                          altas, e analisar que está em ambos os grupo para obter
                          a probabilidade; é verdade se o valor obtido for Probabilidade*/
probEcraNotasAltas(HorasEcra, Nota, Probabilidade) :-
    % tempo ecrã elevado:
    findall(Id,
    (atividade(Id,_,HorasEcra_al,_),
    HorasEcra_al > HorasEcra),                  % filtrar quem tem mais HorasEcra
    Lista_HorasEcra),                           % adicionar os Id's filtrados à lista
    length(Lista_HorasEcra,MuitasHorasEcra),    % nº de alunos que tem muito tempo de ecrã
    % notas altas:
    findall(Id,
    (exame(Id,NotaExame_al),
    NotaExame_al > Nota),       % filtrar alunos cuja NotaExame > Nota referência  
    Lista_NotasAltas),          % adicionar os selecionados à Lista_NotasAltas
    % interseção:
    findall(Id,
    (member(Id,Lista_HorasEcra),            % filtrar alunos que têm tempo de ecrã elevado
    member(Id, Lista_NotasAltas)),          % selecionar os alunos que têm notas altas
    Lista_intersecao),                      % Lista de Id's dos que verificam as condições
    length(Lista_intersecao,Intersecao),    % nº de alunos na lista acima
    % probabilidade condicionada P(A\B)= #P(A^B)/#P(B):
    Probabilidade is round((Intersecao/MuitasHorasEcra) * 100) / 100.

/* subtraiValorDeLista/3 - retira um valor(constante) a todos os elementos da lista;
                           é verdade se o o Resultado for o que se obtem pela operação
                           descrita anteriormente */
subtrair(Valor, X, Y) :- Y is X - Valor.        % definir a subtração por um certo Valor
subtraiValorDeLista(Lista, Valor, Resultado) :-      
    maplist(subtrair(Valor), Lista, Resultado).

/* somaQuadrados/2 - soma os quadrados dos elementos da Lista; é verdade se o Resultado
                     corresponder à operação descrita atrás */
quadrados(X,Y) :- Y is X^2.             % definir a potência (número ao quadrado)
somaQuadrados(Lista, Resultado):-
    maplist(quadrados,Lista,Resultado1),
    sum_list(Resultado1, Resultado).    % somar todos os elementos da lista de quadrados

/* produtoEscalar/3 - efetua o produto escalar de 2 listas, consiste essencialmente na
                      multiplicação de elementos do mesmo índice e posteriormente à
                      soma dos valores obtidos anteriormente */
multiplicacao(X,Y,Z) :- Z is X*Y.                       % definir a multiplicação
produtoEscalar(Lista1, Lista2, Resultado) :-
    length(Lista1,L1),
    length(Lista2,L2),
    L1=:=L2,                                            % tamanhos iguais das listas
    maplist(multiplicacao,Lista1,Lista2,Resultado1),    % multiplicar elementos das listas
    sum_list(Resultado1,Resultado).                     % somar os elementos da lista

/* correlacao/3 - calcula o valor da correlação, este que é obtido através divisão entre
                  o somatório de 1 a n das multiplicações (Xi - média de X) e (Yi - média
                  de Y a dividir pela multiplicação da raíz quadrada do somatório de 1 a 
                  n de (Xi - média de X)^22 com a raiz quadrada do somatório de i a n de 
                  (Yi - média de Y)^2; o predicado é verdade se o Resultado for o valor do
                   Coeficiente de Correlação de Pearson entre X e Y */
correlacao(Lista1,Lista2,Resultado) :-
    % Numerador:
    media(Lista1,Media1),                                       
    media(Lista2,Media2),                                       
    subtraiValorDeLista(Lista1,Media1,Resultado1),              % (Xi - média de X)
    subtraiValorDeLista(Lista2,Media2,Resultado2),              % (Yi - média de Y)
        % somatório das multiplicações (Xi - média de X)*(Yi - média de Y):
    produtoEscalar(Resultado1,Resultado2,Resultado_Numerador),
    % Denominador:
    somaQuadrados(Resultado1,Resultado1_final),                 % (Xi - média de X)^2
    somaQuadrados(Resultado2,Resultado2_final),                 % (Yi - média de Y)^2
        % multiplicação das raízes dos quadrados dos resultados:
    Resultado_Denominador is (sqrt(Resultado1_final))*sqrt(Resultado2_final),
    % Resultado final:
    Resultado is round((Resultado_Numerador/Resultado_Denominador)*100)/100.

% PARTE 2 %
/* tamanho/2 - determina o nº de caracteres de uma palavra; é verdade se Tamanho
               for o comprimento da palavra */
tamanho(Palavra,Tamanho):-
string_chars(Palavra,ListaPalavra), % transformação da palavra em lista
length(ListaPalavra,Tamanho),!.

/* verificaECalcula/4 - o predicado é verdade se garante que os CaracteresPalavra, são os
                        caracteres da Palavra e que as duas palavras tem comprimentos
                        idênticos */
verificaECalcula(Palavra1,Palavra2,CaracteresPalavra1,CaracteresPalavra2) :-
    tamanho(Palavra1,Tamanho1),
    tamanho(Palavra2,Tamanho2),
    Tamanho1 =:= Tamanho2,                  % comparação dos tamanhos das palavra 1 e 2
    string_chars(Palavra1,ListaPalavra1),   % transforma a Palavra1 numa lista
    ListaPalavra1 = CaracteresPalavra1,     % compara as listas
    string_chars(Palavra2,ListaPalavra2),   % transforma a Palavra2 numa lista
    ListaPalavra2 = CaracteresPalavra2,!.   % compara as listas

/* quantasN/3 - determina o nº de palavras que têm comprimento N; é verdade se Quantas
                é o nº de palavras têm comprimento N */
quantasN(Id, N, Quantas) :-
    (Id=pt; Id=mini),                           % validar Id's
    lista_palavras(Id, ListaPalavras),          % apenas considerar palavras válidas      
    findall(Palavra, 
            (member(Palavra, ListaPalavras),    % filtrar pelas palavras da ListaPalavras
             tamanho(Palavra, N)),              % filtrar pelo comprimento da palavra
            Lista),
    length(Lista, Quantas).                     % contar o nº de palavras selecionadas

/* quantasC/3 - verifica se o nº de palavras começadas por C é Quantas; se sim,
                é verdadeiro */
quantasC(Id,C,Quantas) :-
    (Id=pt; Id=mini),                                   % validar Id's
    lista_palavras(Id, ListaPalavras),                  % considerar só palavras válidas                  
    findall(Palavra,(member(Palavra,ListaPalavras),     % filtrar pela ListaPalavras
    string_chars(Palavra,ListaPalavra),
    nth0(0,ListaPalavra,C)),                            % filtrar pela letra inicial
    ListaPalavrasFiltradas),
    length(ListaPalavrasFiltradas,Quantas),!.           % contar as palavras filtradas

/* apagaElemento/3 - verifica se Lista2 resulta da Lista1 após eliminar a primeira
                     vez que dado elemento aparece; se este não se encontrar na Lista1,
                     esta permanece inalterada */
apagaElemento(Elemento, Lista1, Lista2) :-
    selectchk(Elemento,Lista1,Lista2),!.    % apaga a 1ª ocorrência do Elemento na Lista1
apagaElemento(_,Lista,Lista).               % se esse não esteja na Lista1, Lista2=Lista1

/* posicoesPalavra/3 - verifica se Posicoes é a lista alfabeticamente ordenada de
                       tuplos (letra,posisao) resultante da 'decomposição' da palavra 
                       dada */
posicoesPalavra(Palavra,Posicoes) :-
    string_chars(Palavra,ListaPalavra),
    posicoesPalavraAux(ListaPalavra,ListaPalavraIndex,1),   % início da recusão (índice 1)
    sort(ListaPalavraIndex,Posicoes).                       % ordenar a lista de tuplos
    % processo recursivo:
    % caso de paragem:
posicoesPalavraAux([],[],_).                            % ListaPalavra estiver vazia
    % chamada recursiva:
posicoesPalavraAux([H|T],ListaPalavraIndex,Index) :-   
    NewIndex is Index + 1,                              % novo índice -> (índice seguinte)
    posicoesPalavraAux(T,RestoDaLista,NewIndex),        % nova chamada recursiva
    append([(H,Index)],RestoDaLista,ListaPalavraIndex). % ir adicionando (letra,posição)

/* letraIgual/3 - verifica se X e Y são o mesmo carracter; se forem, Z toma o valor 2;
                    caso contrário Z toma o valor 0 */
letraIgual(X,Y,Z):-
    (X==Y -> Z is 2;Z is 0).

/* pista1/2 - é verdade se a Pista é uma Lista com caracteres 0 e 2; 2 nas posições em que
              a letra existe e está no sítio certo e 0, caso contrário. Aqui a Palavra 1 e 
              2, correspondem respetivamente, à palavra mistério e ao palpite */
pista1(Palavra1,Palavra2,Pista) :-
    tamanho(Palavra1,Tamanho1),
    tamanho(Palavra2,Tamanho2),
    Tamanho1 =:= Tamanho2,!,                    % Palpite e Mistério tem o mesmo tamanho
    string_chars(Palavra1,Lista1),              % transformar a Palavra1 numa lista
    string_chars(Palavra2,Lista2),              % transformar a Palavra2 numa lista
    maplist(letraIgual,Lista1,Lista2,Pista).    % verificar semelhança entre listas

/* condicoesAverificar/2 - Este predicado auxiliar é uma variação do predicado letraIgual
                           adaptado para a pista2. Este verifca se a letra está no sítio 
                           certo, Z toma o valor 2; se a letra existir mas estiver no 
                           sítio errado, Z toma o valor 1; caso contrário Z é 0 */
    condicaoAverificar(Lista,X,Y,Z) :-
        (X==Y -> Z is 2;            % a letra existe na palavra, na posição certa
        member(Y,Lista) -> Z is 1;  % a letra existe, na posição errada    
        Z is 0).                    % a letra não existe na palavra

/* pista2/3 - é verdade se a Palavra1 e a Palavra2 tiverem o mesmo tamnanho e for uma 
              lista com caracteres 0,1 e 2. Consoantes as condições descritas no 
              predicado condicoesAverificar */
pista2(Palavra1,Palavra2, Pista) :-
    tamanho(Palavra1,Tamanho1),
    tamanho(Palavra2,Tamanho2),
    Tamanho1 =:= Tamanho2,!,        % Palpite e Mistério tem o mesmo tamanho
    string_chars(Palavra1,Lista1),  % transformar a Palavra1 numa lista
    string_chars(Palavra2,Lista2),  % transformar a Palavra2 numa lista
    maplist(condicaoAverificar(Lista1),Lista1,Lista2,Pista).    % verificar condições

/* letrasCertas/3 - Este predicado pretende auxiliar a pista3. É verdade se Z
                    é un número se já o fosse, se X e Y forem iguais Z toma o valor 2;
                    caso contrário, fica tudo inalterado com Z=Y */
letrasCertasPista(X,Y,Z):-
    (number(Y) -> Z=Y; X==Y -> Z=2; Z=Y).

/* letrasCertasOG/3 - Este predicado visa auxiliar a pista3. É verdade se dois elementos
                      existirem e estiverem no mesmo sítio, aí Z toma o valor 2 */
letrasCertasOG(X,Y,Z) :-
    (X==Y -> Z=2; Z=X).

/* letrasNaoExistentes/3 - Este predicado visa auxiliar a pista3. Aqui, se a X não
                           existir na Palavra1 Z toma o valor 0, senão Z transforma-se
                           em X */
letrasNaoExistentes(Palavra1,X,Z) :-
    (not(memberchk(X,Palavra1))-> Z = 0; Z=X).   

/* atribuirPontosRestantes/3 -Este predicado visa auxiliar a pista3. É verdade se as 
                              pontuações resultar da atribuição de pontos aos elementos
                              da lista segundo algumas condições. Usei um processo 
                              recursivo que atribui 1 (se o elementos não estiver 
                              disponível) e 0 pontos (se o elemento naõ estiver 
                              disponivel), ou não altera o seu valor */ 
    % caso de paragem recursiva:
    atribuirPontosRestantes([],_,[]).   % lista vazia
    % caso recursivo:
    atribuirPontosRestantes([Elem|Resto],Disponiveis, [Pontos|RestoPorPontuar]) :-
        % se for um número, não se altera nada
        (number(Elem)-> Pontos = Elem,  % já foi pontuado e ignora-se
        atribuirPontosRestantes(Resto,Disponiveis,RestoPorPontuar);     % ver o seguinte
        % se for uma letra:
        (select(Elem,Disponiveis,DisponiveisAtualizados) ->
         Pontos = 1,                    % há letras disponíveis
        atribuirPontosRestantes(Resto,DisponiveisAtualizados,RestoPorPontuar);
        Pontos = 0,                     % se não há letras disponíveis
        atribuirPontosRestantes(Resto,Disponiveis,RestoPorPontuar))).            

/* pista3/3 - É verdade se a Pista consiste numa lista com 0,1 e 2 de acordo com os
              critérios explícitos nas funções auxiliares anteriores (letrasCertas,
              letrasCertasOG, letrasNaoExistentes,atribuirPontosRestantes). De modo a 
              chegar à pista da maneira mais eficiente possível optei por uma abordagem
              de transformação progressiva, e simultânea, da Palavra1 e Palavra2.
              1º- atribuição dos 0 pontos; 2º- atribuição dos 2 pontos; 3º- atribuição
              de 1 ou 0 pontos consoantes as letras disponíveis */
pista3(Palavra1,Palavra2,Pista) :-
    tamanho(Palavra1,Tamanho1),
    tamanho(Palavra2,Tamanho2),
    Tamanho1 =:= Tamanho2,!,                    % Palpite e Mistério tem o mesmo tamanho
    string_chars(Palavra1,Lista1),              % transformar a Palavra1 numa lista
    string_chars(Palavra2,Lista2),              % transformar a Palavra2 numa lista

    % atribuição dos 0 pontos: (letras não existentes na palavra)
    maplist(letrasNaoExistentes(Lista1),Lista2,PistaV1),
    % atribuição dos 2 pontos: (letra existe e está corretamente posicionada)
    maplist(letrasCertasPista,Lista1,PistaV1,PistaV2),
    maplist(letrasCertasOG,Lista1,Lista2,PalavraOG_V1), % modifcar a palavra mistério
    % atribuição de 1 ou 0 pontos:
    exclude(number,PalavraOG_V1,LetrasDisponiveis),             % ficam só as letras
    atribuirPontosRestantes(PistaV2, LetrasDisponiveis, Pista). % atribução de pontos 

% PARTE 3 %
/* terror/2 - é verdade se o Filme pertencer à Programacao e, sendo de terror ocupa
              obrigatoriame a posição 3,4 ou 7 na Programacao, correspondentes às sessões
              após as 20h (inclusive) */
terror(Filme1,Programacao) :-
    \+ member(Filme1,Programacao),!.    % garante que o Filme1 integra a Programacao
terror(Filme1,Programacao) :-
    nth1(Posicao1,Programacao,Filme1),
    member(Posicao1,[3,4,7]).           % assegura que a sua posição é válida

/* soPode/3 - é verdade se o Filme só pode ser visto naquela sessao em concreto. Sendo que
              se for de terror fica automanticamente limitado às sessões 3,4 e 7. O 
              objetivo é definir, não deixando ambíguidades, para a posição que o Filme 
              ocupa na Programacao */
soPode(Filme,Sessao,Programacao) :-
    % se for de terror:
    (terror(Filme,Programacao) -> member(Sessao,[3,4,7]); true),
    % se não for de terror:
    (member(Filme,Programacao) -> nth1(Sessao,Programacao,Filme),
    findall(Posicoes, nth1(Posicoes,Programacao,Filme),ListaPosicoes),
    ListaPosicoes == [Sessao]; true).

/* nunca/3 - é verdade se o Filme não ocupara a Sessao na Programação */
nunca(Filme,Sessao,Programacao) :-
    % se for de terror:
    (terror(Filme,Programacao) -> \+ member(Sessao,[3,4,7]);true),
    % se não for de terror:
    (member(Filme,Programacao) ->       % se for membro da Programacao 
    (nth1(Sessao,Programacao,Filme1),   % assume-se Filme1 como o que está a ocupar Sessao
    Filme1\==Filme); true).

/* seguido/3 - é verdade se o Filme2 ocupa a posição imediatamente a seguir à do Filme1 */
seguido(Filme1,Filme2,Programacao) :-
    Filme1 \== empty,                   % não podem ser empty's
    Filme2 \== empty,
    nth1(Posicao1,Programacao,Filme1),  % determinar a posição do Filme1
    Posicao2 is Posicao1 + 1,           % determinar qual deverá ser a posição do Filme2
    Posicao2 =< 7,                      % está limitada ao tamanho da Programacao
    nth1(Posicao2,Programacao,Filme2).  % verificar se coincide com o expectável

/* logoAtras/3 - é verdade se o Filme2 ocupa a posição imediatamente atrás à do Filme1 */
logoAtras(Filme1,Filme2,Programacao) :-
    Filme1 \== empty,                   % não podem ser empty's
    Filme2 \== empty,
    nth1(Posicao1,Programacao,Filme1),  % determinar posiçaõ do Filme1
    Posicao2 is Posicao1 - 1,           % determinar qual deverá ser a posição do Filme2
    Posicao2 >= 1,                      % está limitada ao tamanho da Programacao
    nth1(Posicao2,Programacao,Filme2).  % verificar se coincide com o expectável

/* naoSeguido/3 - é verdade se o Filme2, não estiver imediatamente, nem atrás ou à frente
                  do Filme1 */
naoSeguido(Filme1,Filme2,Programacao) :-
    \+(seguido(Filme1,Filme2,Programacao)),
    \+(logoAtras(Filme1,Filme2,Programacao)).   

/* antes/3 - é verdade se o Filme1 estiver antes do Filme2 na Programacao */
antes(Filme1,Filme2,Programacao) :-
    nth1(Posicao1,Programacao,Filme1),  % determinar a posição do Filme1 em Programacao
    nth1(Posicao2,Programacao,Filme2),  % determinar a posição do Filme2 em Programacao
    Posicao1 < Posicao2.                % verificar se o Filme1 está antes do 2

/* listaEmpty/2 - visa a criação de uma lista com NumeroEmpty de Empty's
                 (através de recursão)*/
    % caso de paragem:                 
listaDeEmpty(0,_,[]).               % lista vazia
    % caso recursivo:
listaDeEmpty(N,Elem,[Elem|Resto]) :-
    N>0,
    NewN is N-1,                    % N vai diminuindo até atingir 0
    listaDeEmpty(NewN,Elem,Resto).  % chamada recursiva

/* verificaRestricoes/2 - garante que todas as restrições são aplicadas */
    % caso de paragem recursiva:
verificaRestricoes(_,[]).   % se a ListaRestricoes estiver vazia, foram todas satisfeitas
    % caso recursivo:
verificaRestricoes(Programacao,[Restricao|RestantesRestricoes]) :-
    ativarRestricao(Restricao,Programacao),
    verificaRestricoes(Programacao,RestantesRestricoes).

/* AtivarRestricao/2 - chama a restrição definida previamente e aplica-a */
ativarRestricao(soPode(Filme,Sessao),Programacao) :-
    soPode(Filme,Sessao,Programacao).
ativarRestricao(terror(Filme),Programacao) :-
    terror(Filme,Programacao).
ativarRestricao(nunca(Filme,Sessao),Programacao) :- 
    nunca(Filme,Sessao,Programacao).
ativarRestricao(seguido(Filme1,Filme2),Programacao) :-
    seguido(Filme1,Filme2,Programacao).
ativarRestricao(naoSeguido(Filme1,Filme2),Programacao) :-
    naoSeguido(Filme1,Filme2,Programacao).
ativarRestricao(antes(Filme1,Filme2),Programacao) :-
    antes(Filme1,Filme2,Programacao).            

/* maratonaFilmes/3 - é verdade a Programacao contiver Filmes da Lista de Filmes, 
                      assegurando a satisfação de todas as restrições na ListaRestrições*/
maratonaFilmes(ListaFilmes, ListaRestricoes, Programacao) :-
    % verificar tamanho ListaFilmes (máximo de 7 filmes):
    length(ListaFilmes,NumeroFilmes),
    NumeroFilmes =< 7,
    % estrutura da Programacao:
    NumeroEmpty is 7- NumeroFilmes,                     % nº de  'empty's' em Programacao
    listaDeEmpty(NumeroEmpty,empty,ListaEmpty),         % lista com NumeroEmpty de Empty's
        % criação de uma lista com todos os filmes e 'empty's' das sessoes a preencher:
    append(ListaFilmes,ListaEmpty,ListaDesordenada),
        % encontrar todas as soluções viáveis:
    findall(Possibilidade,
    (permutation(ListaDesordenada,Possibilidade),
    verificaRestricoes(Possibilidade,ListaRestricoes)),
    ProgramacaoComRepetido),
    sort(ProgramacaoComRepetido,Programacao),!.
