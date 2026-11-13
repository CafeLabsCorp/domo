# Google Play — Segurança dos dados (Data Safety) do Domo

**Rascunho de respostas, 12 de novembro de 2026.** Baseado no código do app lido
nesta data. Preencher na Play Console em **Conteúdo do app → Segurança dos
dados**. Se o app mudar o que coleta (ou se as correções abaixo não forem
feitas), as respostas mudam.

As respostas assumem que, **antes de enviar**, foram feitas as três mudanças
de código listadas em "Pré-requisitos". Se alguma não for feita, use a
variante indicada.

## Pré-requisitos (código)

1. **Advertising ID desligado** no Android (remover a permissão `AD_ID` do
   manifest mesclado e desligar a coleta de ADID do Analytics). Sem isso:
   declarar "Device or other IDs" também com o ID de publicidade, e responder
   "Sim" na declaração de ID de publicidade.
2. **Exclusão de conta** dentro do app **e** página web pública. Sem isso, a
   resposta "Você oferece uma forma de os usuários pedirem a exclusão dos
   dados?" fica "Sim" só pelo e-mail, e a Play exige a URL de exclusão de
   qualquer forma; o app fica fora da política.
3. **Opção de desligar a medição de uso** no app. Sem isso, os dados de
   Analytics são "obrigatórios" em vez de "opcionais".

## Visão geral

| Pergunta | Resposta |
|---|---|
| O app coleta ou compartilha algum dos tipos de dados do usuário exigidos? | **Sim** |
| Todos os dados coletados são criptografados em trânsito? | **Sim** (Firebase usa HTTPS/TLS) |
| Você oferece uma forma de os usuários pedirem a exclusão dos dados? | **Sim** (no app + URL web + e-mail) |
| URL de exclusão de conta | `TODO: confirmar` (sugestão: `https://domo.cafelabs.net/excluir-conta`) |
| O app permite criar conta? | **Sim** (e-mail/senha e Google) |
| Login com conta de terceiro? | **Sim** (Google) |

## Tipos de dados

"Compartilhado" = **Não** em todos: o Google atua como prestador de serviço
(Firebase), o que a Play não conta como compartilhamento. Isso depende de
**sinais do Google** e **compartilhamento de dados** desligados no Google
Analytics (`TODO: confirmar` no console). "Processado de forma efêmera" =
**Não** em todos.

| Categoria → tipo | Coletado | Obrigatório ou opcional | Finalidades | Origem no código |
|---|---|---|---|---|
| Informações pessoais → **Nome** | Sim | Opcional (só com login Google) | Funcionalidade do app; Gerenciamento da conta | Firebase Auth `displayName`, gravado em `casas/{id}.membros[uid].nome` |
| Informações pessoais → **Endereço de e-mail** | Sim | Obrigatório | Funcionalidade do app; Gerenciamento da conta | Firebase Auth; também gravado como nome exibido do membro quando não há nome |
| Informações pessoais → **IDs do usuário** | Sim | Obrigatório | Funcionalidade do app; Gerenciamento da conta | UID do Firebase Auth em `membros`, `membrosAtivos`, `criadoPor`, `atualizadoPor` |
| Fotos e vídeos → **Fotos** | Sim (conservador) | Opcional (só com login Google) | Funcionalidade do app | link da foto de perfil Google em `membros[uid].fotoUrl`, mostrada aos membros. O app guarda o link, não o arquivo; declarar é a opção mais segura |
| Atividade no app → **Outros conteúdos gerados pelo usuário** | Sim | Obrigatório | Funcionalidade do app | nome da casa, nome/categoria/status/quantidade dos itens |
| Atividade no app → **Interações com o app** | Sim | Opcional (com o opt-out) | Análise | telas, sessões e os 6 eventos do `analytics_service.dart` |
| Localização → **Localização aproximada** | Sim | Opcional (com o opt-out) | Análise | Google Analytics deriva do IP |
| Dispositivo ou outros IDs → **Dispositivo ou outros IDs** | Sim | Opcional (com o opt-out) | Análise | ID de instância do app / ID de instalação do Firebase (e o ID de publicidade, se não for desligado) |

**Não coletados** (deixar desmarcado): endereço, telefone, raça/etnia,
religião, orientação sexual, outras informações pessoais, informações
financeiras (todas), saúde e condicionamento físico, mensagens, fotos/vídeos
além do acima, áudio, arquivos e documentos, agenda, contatos, histórico de
pesquisa no app, apps instalados, histórico de navegação na web, localização
precisa, registros de falhas e diagnósticos (o app não usa Crashlytics).

Observação: o Firebase Auth registra IP e user agent no cadastro e no login para
segurança. A Play não tem tipo específico para IP; o uso de segurança está
coberto pela coleta de e-mail/ID para "Gerenciamento da conta" e pela
localização aproximada. `TODO: confirmar` se o Felipe prefere marcar também
"Prevenção de fraudes, segurança e conformidade" como finalidade de e-mail e IDs
do usuário (recomendado, e não custa nada).

## Outras declarações em "Conteúdo do app"

| Seção | Resposta |
|---|---|
| Política de privacidade | URL pública da política (`TODO: confirmar`, sugestão `https://domo.cafelabs.net/privacidade`). Não pode ser PDF, precisa abrir sem login |
| Anúncios | **Não**, o app não contém anúncios |
| Acesso ao app | **Todas ou algumas funcionalidades são restritas**: criar uma conta de teste com e-mail e senha **já dentro de uma casa com alguns itens**, e informar as credenciais e o passo a passo (login → despensa). Sem isso, a revisão para na tela de login |
| ID de publicidade | **Não** (se o pré-requisito 1 for feito); senão **Sim**, finalidade "Análise" |
| Classificação do conteúdo (IARC) | Categoria "Utilitário, produtividade, comunicação ou outro". Violência, sexo, linguagem, drogas, apostas: **Não**. "Usuários interagem ou trocam conteúdo?": **Sim** (membros da casa veem nomes e itens uns dos outros; grupo fechado, por convite). Compartilha localização com outros usuários: **Não**. Compras digitais: **Não**. Resultado esperado: Livre / Everyone / PEGI 3, com o descritor "Usuários interagem". Conferir no questionário real |
| Público-alvo e conteúdo | **18 anos ou mais** (se a decisão de idade mínima seguir o Dindin). Se incluir 13–17, a Play pede justificativa e o texto legal muda. Nunca incluir menores de 13 sem a política de Famílias. "O app pode atrair crianças sem querer?": **Não** |
| Apps de notícias, governo, saúde, recursos financeiros | **Não** em todos |

## Para o futuro

Se a Café Labs publicar o Domo na Apple App Store, o rótulo "Privacidade do
app" da Apple é outro formulário, com outras categorias (por exemplo, "Dados
vinculados a você" e "Dados usados para rastrear você"). Esta folha não cobre
isso.

> Estas respostas são um rascunho para conferir contra o app real antes do envio.
> Não substituem a revisão jurídica da Política de Privacidade, e a Política e o
> formulário precisam dizer a mesma coisa.
