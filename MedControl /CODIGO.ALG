
algoritmo "MedControl - Gerenciamento de Atendimentos"

const
   MAX_PACIENTES = 30
   EMERGENCIA = 1
   MUITO_URGENTE = 2
   URGENTE = 3
   POUCO_URGENTE = 4
   AGUARDANDO = 0
   ATENDIDO = 1
   NAO_ENCONTRADO = 0
   COL_CADASTRADOS = 1
   COL_AGUARDANDO = 2
   COL_ATENDIDOS = 3
   IDADE_MINIMA = 0
   IDADE_MAXIMA = 120
   PAS_MINIMA = 50
   PAS_MAXIMA = 300
   PAD_MINIMA = 30
   PAD_MAXIMA = 200
   TEMP_MINIMA = 30
   TEMP_MAXIMA = 45

tipo
   registro_paciente = registro
      codigo: inteiro
      nome: caractere
      idade: inteiro
      sexo: caractere
      prioridade: inteiro
      pas: inteiro
      pad: inteiro
      temperatura: real
      status: inteiro
   fimregistro

var
   // Vetor com os dados dos pacientes
   pacientes: vetor[1..30] de registro_paciente

   // Fila guarda as posicoes dos pacientes
   fila: vetor[1..30] de inteiro

   // Matriz: 4 prioridades e 3 situacoes
   estatisticas: vetor[1..4,1..3] de inteiro

   qtdPacientes, opcao: inteiro
   encerrar: logico


// ==================================================
// FUNCOES AUXILIARES
// ==================================================

funcao nomePrioridade(p: inteiro): caractere
var texto: caractere
inicio
   se p = EMERGENCIA entao
      texto <- "Emergencia"
   senao
      se p = MUITO_URGENTE entao
         texto <- "Muito urgente"
      senao
         se p = URGENTE entao
            texto <- "Urgente"
         senao
            texto <- "Pouco urgente"
         fimse
      fimse
   fimse
   retorne texto
fimfuncao


funcao nomeStatus(s: inteiro): caractere
var texto: caractere
inicio
   se s = AGUARDANDO entao
      texto <- "Aguardando"
   senao
      texto <- "Atendido"
   fimse
   retorne texto
fimfuncao


funcao nomeColuna(c: inteiro): caractere
var texto: caractere
inicio
   se c = COL_CADASTRADOS entao
      texto <- "Cadastrados"
   senao
      se c = COL_AGUARDANDO entao
         texto <- "Aguardando"
      senao
         texto <- "Atendidos"
      fimse
   fimse
   retorne texto
fimfuncao


funcao calcularMedia(soma: real; quantidade: inteiro): real
var resultado: real
inicio
   se quantidade = 0 entao
      resultado <- 0
   senao
      resultado <- soma / quantidade
   fimse
   retorne resultado
fimfuncao


funcao calcularPercentual(parte, total: inteiro): real
var
   resultado: real
inicio
   se total = 0 entao
      resultado <- 0
   senao
      resultado <- parte / total
      resultado <- resultado * 100
   fimse

   retorne resultado
fimfuncao

// ==================================================
// BUSCA ITERATIVA
// ==================================================

funcao buscarPaciente(codigo: inteiro): inteiro
var i, resultado: inteiro
inicio
   resultado <- NAO_ENCONTRADO
   i <- 1

   enquanto (i <= qtdPacientes) e (resultado = NAO_ENCONTRADO) faca
      se pacientes[i].codigo = codigo entao
         resultado <- i
      fimse
      i <- i + 1
   fimenquanto

   retorne resultado
fimfuncao


// ==================================================
// BUSCA RECURSIVA
// ==================================================

funcao buscaRecursiva(codigo, posicao, n: inteiro): inteiro
var resultado: inteiro
inicio
   se posicao > n entao
      resultado <- NAO_ENCONTRADO
   senao
      se pacientes[posicao].codigo = codigo entao
         resultado <- posicao
      senao
         resultado <- buscaRecursiva(codigo, posicao + 1, n)
      fimse
   fimse

   retorne resultado
fimfuncao


// ==================================================
// CONTAGEM RECURSIVA DOS QUE AGUARDAM
// ==================================================

funcao qtdAguardandoRec(posicao, n: inteiro): inteiro
var atual, resultado: inteiro
inicio
   se posicao > n entao
      resultado <- 0
   senao
      se pacientes[posicao].status = AGUARDANDO entao
         atual <- 1
      senao
         atual <- 0
      fimse

      resultado <- atual + qtdAguardandoRec(posicao + 1, n)
   fimse

   retorne resultado
fimfuncao


// ==================================================
// ORDENACAO DA FILA
// ==================================================

// Verifica qual paciente deve ser atendido primeiro
funcao precede(a, b: inteiro): logico
var resultado: logico
inicio
   se pacientes[a].prioridade <> pacientes[b].prioridade entao
      resultado <- pacientes[a].prioridade < pacientes[b].prioridade
   senao
      se pacientes[a].idade <> pacientes[b].idade entao
         resultado <- pacientes[a].idade > pacientes[b].idade
      senao
         resultado <- a < b
      fimse
   fimse

   retorne resultado
fimfuncao


// Monta a fila com os pacientes que estao aguardando
funcao montarFila: inteiro
var i, contador: inteiro
inicio
   contador <- 0

   para i de 1 ate qtdPacientes faca
      se pacientes[i].status = AGUARDANDO entao
         contador <- contador + 1
         fila[contador] <- i
      fimse
   fimpara

   retorne contador
fimfuncao


// Ordenacao pelo metodo da bolha
procedimento ordenarFila(qtd: inteiro)
var i, j, aux: inteiro
inicio
   para i de 1 ate qtd faca
      para j de 1 ate qtd - i faca
         se precede(fila[j + 1], fila[j]) entao
            aux <- fila[j]
            fila[j] <- fila[j + 1]
            fila[j + 1] <- aux
         fimse
      fimpara
   fimpara
fimprocedimento


// ==================================================
// MATRIZ DE ESTATISTICAS
// ==================================================

procedimento inicializarMatriz
var lin, col: inteiro
inicio
   para lin de 1 ate 4 faca
      para col de 1 ate 3 faca
         estatisticas[lin,col] <- 0
      fimpara
   fimpara
fimprocedimento


procedimento atualizarMatrizCadastro(prioridade: inteiro)
inicio
   estatisticas[prioridade,1] <- estatisticas[prioridade,1] + 1
   estatisticas[prioridade,2] <- estatisticas[prioridade,2] + 1
fimprocedimento


procedimento atualizarMatrizAtendimento(prioridade: inteiro)
inicio
   estatisticas[prioridade,COL_AGUARDANDO] <- estatisticas[prioridade,COL_AGUARDANDO] - 1
   estatisticas[prioridade,COL_ATENDIDOS] <- estatisticas[prioridade,COL_ATENDIDOS] + 1
fimprocedimento


// ==================================================
// EXIBICAO DE PACIENTE
// ==================================================

procedimento exibirPaciente(indice: inteiro)
inicio
   escreval("Codigo: ", pacientes[indice].codigo," | Nome: ", pacientes[indice].nome)

   escreval("Idade: ", pacientes[indice].idade," | Sexo: ", pacientes[indice].sexo)

   escreval("Prioridade: ", pacientes[indice].prioridade," - ", nomePrioridade(pacientes[indice].prioridade))

   escreval("Pressao: ", pacientes[indice].pas, "/",pacientes[indice].pad, " mmHg")

   escreval("Temperatura: ", pacientes[indice].temperatura:5:1, " C")

   escreval("Status: ", nomeStatus(pacientes[indice].status))
   escreval("----------------------------------------------")
fimprocedimento


// ==================================================
// MENU PRINCIPAL
// ==================================================

procedimento exibirMenu
inicio
   escreval("")
   escreval("==============================================")
   escreval(" MEDCONTROL - GERENCIAMENTO DE ATENDIMENTOS")
   escreval("==============================================")
   escreval("1 - Cadastrar paciente")
   escreval("2 - Listar pacientes")
   escreval("3 - Consultar paciente")
   escreval("4 - Exibir fila de atendimento")
   escreval("5 - Realizar atendimento")
   escreval("6 - Exibir pacientes atendidos")
   escreval("7 - Exibir estatisticas")
   escreval("8 - Executar consulta recursiva")
   escreval("9 - Encerrar sistema")
   escreval("==============================================")
   escreva("Escolha uma opcao: ")
fimprocedimento


// ==================================================
// 1. CADASTRAR PACIENTE
// ==================================================

procedimento cadastrarPaciente
var
   codigo, idade, prioridade, pas, pad: inteiro
   posicao: inteiro
   nome, sexo: caractere
   temperatura: real
inicio
   se qtdPacientes >= MAX_PACIENTES entao
      escreval("Limite de pacientes atingido.")
   senao
      escreval("--- CADASTRO DE PACIENTE ---")

      repita
         escreva("Codigo positivo: ")
         leia(codigo)

         se codigo <= 0 entao
            escreval("Codigo deve ser maior que zero.")
         senao
            se buscarPaciente(codigo) <> NAO_ENCONTRADO entao
               escreval("Esse codigo ja esta cadastrado.")
               codigo <- 0
            fimse
         fimse
      ate codigo > 0

      repita
         escreva("Nome: ")
         leia(nome)

         se compr(nome) = 0 entao
            escreval("O nome nao pode ficar vazio.")
         fimse
      ate compr(nome) > 0

      repita
         escreva("Idade (0 a 120): ")
         leia(idade)

         se (idade < IDADE_MINIMA) ou (idade > IDADE_MAXIMA) entao
            escreval("Idade invalida.")
         fimse
      ate (idade >= IDADE_MINIMA) e (idade <= IDADE_MAXIMA)

      repita
         escreva("Sexo (M/F): ")
         leia(sexo)

         se (sexo <> "M") e (sexo <> "F") entao
            escreval("Digite M ou F.")
         fimse
      ate (sexo = "M") ou (sexo = "F")

      repita
         escreval("1-Emergencia  2-Muito urgente")
         escreval("3-Urgente     4-Pouco urgente")
         escreva("Prioridade: ")
         leia(prioridade)

         se (prioridade < 1) ou (prioridade > 4) entao
            escreval("Prioridade invalida.")
         fimse
      ate (prioridade >= 1) e (prioridade <= 4)

      repita
         escreva("Pressao sistolica (50 a 300): ")
         leia(pas)

         se (pas < PAS_MINIMA) ou (pas > PAS_MAXIMA) entao
            escreval("Valor invalido.")
         fimse
      ate (pas >= PAS_MINIMA) e (pas <= PAS_MAXIMA)

      repita
         escreva("Pressao diastolica (30 a 200): ")
         leia(pad)

         se (pad < PAD_MINIMA) ou (pad > PAD_MAXIMA) entao
            escreval("Valor invalido.")
         senao
            se pad >= pas entao
               escreval("A diastolica deve ser menor que a sistolica.")
            fimse
         fimse
      ate (pad >= PAD_MINIMA) e (pad <= PAD_MAXIMA) e (pad < pas)

      repita
         escreva("Temperatura (30 a 45 C): ")
         leia(temperatura)

         se (temperatura < TEMP_MINIMA) ou (temperatura > TEMP_MAXIMA) entao
            escreval("Temperatura invalida.")
         fimse
      ate (temperatura >= TEMP_MINIMA) e (temperatura <= TEMP_MAXIMA)

      qtdPacientes <- qtdPacientes + 1
      posicao <- qtdPacientes

      pacientes[posicao].codigo <- codigo
      pacientes[posicao].nome <- nome
      pacientes[posicao].idade <- idade
      pacientes[posicao].sexo <- sexo
      pacientes[posicao].prioridade <- prioridade
      pacientes[posicao].pas <- pas
      pacientes[posicao].pad <- pad
      pacientes[posicao].temperatura <- temperatura
      pacientes[posicao].status <- AGUARDANDO

      atualizarMatrizCadastro(prioridade)

      escreval("Paciente cadastrado com sucesso!")
   fimse
fimprocedimento


// ==================================================
// 2. LISTAR PACIENTES
// ==================================================

procedimento listarPacientes
var i: inteiro
inicio
   se qtdPacientes = 0 entao
      escreval("Nenhum paciente cadastrado.")
   senao
      para i de 1 ate qtdPacientes faca
         exibirPaciente(i)
      fimpara
   fimse
fimprocedimento


// ==================================================
// 3. CONSULTAR PACIENTE
// ==================================================

procedimento consultarPaciente
var codigo, posicao: inteiro
inicio
   se qtdPacientes = 0 entao
      escreval("Nenhum paciente cadastrado.")
   senao
      escreva("Codigo do paciente: ")
      leia(codigo)

      posicao <- buscarPaciente(codigo)

      se posicao = NAO_ENCONTRADO entao
         escreval("Paciente nao encontrado.")
      senao
         exibirPaciente(posicao)
      fimse
   fimse
fimprocedimento


// ==================================================
// 4. EXIBIR FILA
// ==================================================

procedimento exibirFilaAtendimento
var qtdFila, i: inteiro
inicio
   qtdFila <- montarFila

   se qtdFila = 0 entao
      escreval("Nao ha pacientes aguardando.")
   senao
      ordenarFila(qtdFila)

      escreval("--- FILA DE ATENDIMENTO ---")

      para i de 1 ate qtdFila faca
         escreval("Posicao na fila: ", i)
         exibirPaciente(fila[i])
      fimpara
   fimse
fimprocedimento


// ==================================================
// CONCLUIR ATENDIMENTO
// ==================================================

procedimento concluirAtendimento(posicao: inteiro)
inicio
   pacientes[posicao].status <- ATENDIDO

   atualizarMatrizAtendimento(pacientes[posicao].prioridade)

   escreval("Atendimento realizado com sucesso!")
   exibirPaciente(posicao)
fimprocedimento


// ==================================================
// 5. REALIZAR ATENDIMENTO
// ==================================================

procedimento realizarAtendimento
var qtdFila, codigo, posicao: inteiro
inicio
   se qtdPacientes = 0 entao
      escreval("Nenhum paciente cadastrado.")
   senao
      qtdFila <- montarFila

      se qtdFila = 0 entao
         escreval("Nao ha pacientes aguardando atendimento.")
      senao
         ordenarFila(qtdFila)

         escreval("Digite 0 para atender o proximo da fila.")
         escreva("Ou digite o codigo do proximo paciente: ")
         leia(codigo)

         se codigo = 0 entao
            concluirAtendimento(fila[1])
         senao
            posicao <- buscarPaciente(codigo)

            se posicao = NAO_ENCONTRADO entao
               escreval("Paciente nao encontrado.")
            senao
               se pacientes[posicao].status = ATENDIDO entao
                  escreval("Esse paciente ja foi atendido.")
               senao
                  se posicao <> fila[1] entao
                     escreval("Esse paciente nao e o proximo da fila.")
                     escreval("Proximo paciente: ", pacientes[fila[1]].nome)
                  senao
                     concluirAtendimento(posicao)
                  fimse
               fimse
            fimse
         fimse
      fimse
   fimse
fimprocedimento


// ==================================================
// 6. EXIBIR PACIENTES ATENDIDOS
// ==================================================

procedimento exibirAtendidos
var i, contador: inteiro
inicio
   contador <- 0

   para i de 1 ate qtdPacientes faca
      se pacientes[i].status = ATENDIDO entao
         exibirPaciente(i)
         contador <- contador + 1
      fimse
   fimpara

   se contador = 0 entao
      escreval("Nenhum paciente foi atendido.")
   senao
      escreval("Total de atendidos: ", contador)
   fimse
fimprocedimento


// ==================================================
// 7. EXIBIR ESTATISTICAS
// ==================================================


procedimento exibirEstatisticas
var
   i, lin, col: inteiro
   qtdAguardando, qtdAtendidos: inteiro
   qtdPrioridade12, maiorIdade, menorIdade: inteiro
   somaIdades, somaTemperaturas: real
   mediaIdade, mediaTemperatura: real
   percAtendidos, percAguardando: real
inicio
   se qtdPacientes = 0 entao
      escreval("Nao ha dados para calcular.")
   senao

      // Inicializa os contadores e as somas
      somaIdades <- 0
      somaTemperaturas <- 0
      qtdAtendidos <- 0
      qtdAguardando <- 0
      qtdPrioridade12 <- 0

      // Inicializa a maior e a menor idade
      maiorIdade <- pacientes[1].idade
      menorIdade <- pacientes[1].idade

      // Percorre os pacientes cadastrados
      para i de 1 ate qtdPacientes faca

         somaIdades <- somaIdades + pacientes[i].idade
         somaTemperaturas <- somaTemperaturas + pacientes[i].temperatura

         se pacientes[i].idade > maiorIdade entao
            maiorIdade <- pacientes[i].idade
         fimse

         se pacientes[i].idade < menorIdade entao
            menorIdade <- pacientes[i].idade
         fimse

         // Conta pacientes atendidos e aguardando
         se pacientes[i].status = ATENDIDO entao
            qtdAtendidos <- qtdAtendidos + 1
         senao
            qtdAguardando <- qtdAguardando + 1
         fimse

         // Conta pacientes de prioridade 1 ou 2
         se (pacientes[i].prioridade = EMERGENCIA) ou (pacientes[i].prioridade = MUITO_URGENTE) entao
            qtdPrioridade12 <- qtdPrioridade12 + 1
         fimse

      fimpara

      // Calcula as medias
      mediaIdade <- calcularMedia(somaIdades, qtdPacientes)
      mediaTemperatura <- calcularMedia(somaTemperaturas, qtdPacientes)

      // Calcula os percentuais
      percAtendidos <- calcularPercentual(qtdAtendidos, qtdPacientes)
      percAguardando <- calcularPercentual(qtdAguardando, qtdPacientes)

      // Exibe as estatisticas gerais
      escreval("========== ESTATISTICAS ==========")
      escreval("Total de pacientes: ", qtdPacientes)
      escreval("Aguardando: ", qtdAguardando)
      escreval("Atendidos: ", qtdAtendidos)
      escreval("Percentual atendidos: ", percAtendidos:6:2, "%")
      escreval("Percentual aguardando: ", percAguardando:6:2, "%")
      escreval("Media de idade: ", mediaIdade:6:1)
      escreval("Media de temperatura: ", mediaTemperatura:5:1, " C")
      escreval("Maior idade: ", maiorIdade)
      escreval("Menor idade: ", menorIdade)
      escreval("Prioridade 1 ou 2: ", qtdPrioridade12)

      // Exibe a matriz de estatisticas
      escreval("--- MATRIZ DE ESTATISTICAS ---")

      para lin de 1 ate 4 faca
         escreva(nomePrioridade(lin), ": ")

         para col de 1 ate 3 faca
            escreva(nomeColuna(col), " = ")
            escreva(estatisticas[lin,col], " | ")
         fimpara

         escreval("")
      fimpara

      escreval("=================================")

   fimse
fimprocedimento




// ==================================================
// 8. CONSULTA RECURSIVA
// ==================================================

procedimento executarConsultaRecursiva
var codigo, posicao: inteiro
inicio
   se qtdPacientes = 0 entao
      escreval("Nenhum paciente cadastrado.")
   senao
      escreva("Codigo para busca recursiva: ")
      leia(codigo)

      posicao <- buscaRecursiva(codigo, 1, qtdPacientes)

      se posicao = NAO_ENCONTRADO entao
         escreval("Paciente nao encontrado.")
      senao
         escreval("Paciente encontrado na posicao: ", posicao)
         exibirPaciente(posicao)
      fimse

      escreval("Aguardando atendimento: ",qtdAguardandoRec(1, qtdPacientes))
   fimse
fimprocedimento


// ==================================================
// PROGRAMA PRINCIPAL
// ==================================================

inicio
   qtdPacientes <- 0
   encerrar <- falso

   inicializarMatriz

   enquanto nao encerrar faca
      exibirMenu
      leia(opcao)

      escolha opcao
         caso 1
            cadastrarPaciente
         caso 2
            listarPacientes
         caso 3
            consultarPaciente
         caso 4
            exibirFilaAtendimento
         caso 5
            realizarAtendimento
         caso 6
            exibirAtendidos
         caso 7
            exibirEstatisticas
         caso 8
            executarConsultaRecursiva
         caso 9
            escreval("Encerrando o MedControl.")
            encerrar <- verdadeiro
         outrocaso
            escreval("Opcao invalida. Escolha de 1 a 9.")
      fimescolha
   fimenquanto

fimalgoritmo
