# Política de Privacidade — Domo

**Versão 0.2 (RASCUNHO), 13 de novembro de 2026**
**Status: NÃO revisada por advogado(a). Não publicar nem usar como proteção real antes da revisão.**

> Notas internas (não fazem parte do texto público):
>
> - Publicação prevista: `TODO: confirmar` URL. Sugestão, no padrão do Dindin:
>   `https://domo.cafelabs.net/privacidade` (HTML público, indexável, sem login,
>   **não** PDF). A mesma URL vai na Play Console e precisa estar linkada
>   **dentro do app** (Perfil → Privacidade e termos).
> - Este rascunho foi escrito a partir do código real do repositório `domo`
>   (lido em 2026-11-12): `firestore.rules`, `lib/features/**`,
>   `lib/core/analytics/analytics_service.dart`, `pubspec.yaml`,
>   `AndroidManifest.xml`, e da landing `domo-landing` (Vercel Analytics).
>   Se o app mudar o que coleta, esta política precisa mudar junto.
> - Versão 0.2 (2026-11-13): atualizada para o app como está agora (exclusão de
>   conta, opt-out da medição, nome de exibição no cadastro, pendente sem
>   acesso à lista de membros, Advertising ID removido, projeto
>   `domo-cafelabs` com Firestore em `southamerica-east1`) e para a decisão de
>   aceitar 13 anos ou mais. Todas as funções descritas existem no código.
> - Trechos marcados `TODO: confirmar` dependem de decisão do Felipe, de
>   conferência no console (Firebase, Analytics) ou do advogado.
> - Documento separado dos Termos de Uso (`termos-de-uso.md`), de propósito.

---

## 1. Em linguagem simples

O Domo é um aplicativo para organizar a casa em grupo: uma despensa
compartilhada (o que tem, o que acabou, o que está no carrinho) e uma lista de
compras que sai dela. Você cria uma "casa" ou entra numa casa que já existe
usando um código de convite, e todos os membros veem e editam a mesma lista.

Para isso o Domo precisa de uma conta (e-mail, ou login com Google). **Os
membros da sua casa veem o seu nome e, se você entrou com Google, a sua foto.**
É assim que eles sabem quem está na casa. O seu e-mail não aparece para os
outros membros.

O Domo **não vende dados, não mostra anúncios, não pede CPF, endereço,
telefone, localização por GPS ou dados de pagamento**. Ele não faz compras por
você: a lista é só uma anotação.

O resto deste documento explica isso em detalhe, porque a lei exige que a
explicação seja completa.

## 2. Quem é responsável pelos seus dados

**Controlador (quem decide quais dados existem e por quê):**
Café Labs, operada por Felipe Portes Antunes. A Café Labs ainda não possui CNPJ
próprio. `TODO: confirmar` se continua sem CNPJ na data de publicação; se tiver,
trocar por razão social e CNPJ.

**Operadores (quem processa dados por conta da Café Labs):**

- **Google LLC / Google Cloud — Firebase Authentication e Cloud Firestore:**
  guardam a sua conta e os dados da casa.
- **Google LLC — Firebase Hosting:** entrega o aplicativo web
  (`app.domo.cafelabs.net`).
- **Google LLC — Google Analytics para Firebase:** processa a medição de uso
  descrita na seção 3.6.
- **Google LLC — Google Fonts:** fornece as fontes do aplicativo, baixadas
  quando o app abre (o seu endereço IP chega ao Google nessa hora).
- **Vercel Inc.:** hospeda apenas o site de apresentação `domo.cafelabs.net`,
  que não tem login nem recebe dados da sua conta.

**Canal de contato sobre privacidade:** `privacidade@cafelabs.net`.

A Café Labs é hoje um agente de tratamento de pequeno porte e, nos termos da
Resolução CD/ANPD nº 2/2022, está dispensada de indicar formalmente um(a)
Encarregado(a), mas mantém este canal de comunicação com você e com a ANPD,
como a mesma norma exige. Se o volume ou a natureza do tratamento mudar, a
indicação será feita e esta política será atualizada.

## 3. Quais dados são tratados

### 3.1 Dados da sua conta

Criados quando você se cadastra, e guardados pelo Firebase Authentication:

- **E-mail**: identificador de login. Não é mostrado aos outros membros das
  casas.
- **Nome**: o que você digita no cadastro com e-mail e senha, ou o nome da sua
  conta Google. É o nome que os membros da casa veem.
- **Senha**: só se você se cadastrou com e-mail e senha. É guardada pelo Google
  de forma cifrada e **não é legível pela Café Labs**.
- **Foto de perfil da conta Google**: só se você usar "Entrar com Google".
  Vem da sua conta Google; o Domo não pede esse dado a você.
- **Identificador interno da conta (UID)**: código gerado pelo Firebase que
  liga você às casas de que participa.
- **Datas de criação da conta e do último acesso**, e o **endereço IP** usado no
  cadastro e no login, registrados pelo Firebase Authentication para segurança
  e prevenção de abuso.
- **Registro de aceite**: a versão dos Termos de Uso e da Política de
  Privacidade que você aceitou e a data e hora do aceite. Fica num registro
  privado seu no Cloud Firestore, que só você acessa, e serve para comprovar
  que o aceite ocorreu.
- **Lista de casas em que você aguarda aprovação**: um registro privado, também
  só seu, com o código das casas em que você pediu para entrar e ainda não foi
  aprovado. Existe para que a exclusão da conta consiga limpar esses pedidos.

### 3.2 Dados da casa e dos membros (visíveis para os outros membros)

Quando você cria uma casa ou entra numa, o Domo guarda no Cloud Firestore:

- **Da casa**: o nome que o criador deu, o código de convite de 6 caracteres,
  quem criou e quando, e a ordem escolhida para as categorias da despensa.
- **De cada membro, inclusive você**:
  - **nome exibido**: o nome que você digitou no cadastro com e-mail e senha
    ou o nome da sua conta Google (se a conta não tiver nome, aparece
    "Usuário");
  - **link da foto de perfil** da conta Google, se houver;
  - **cargo** ("Administrador" ou "Membro", só um rótulo);
  - **situação**: ativo ou pendente (aguardando aprovação).

**Quem vê esses dados:** os membros **ativos** da casa. Quem digita o código de
convite e pede para entrar fica como **pendente** e **não vê a lista de
membros nem os itens** enquanto não for aprovado; vê apenas o nome da casa, que
o código revela. Mesmo assim, compartilhe o código só com quem você conhece.

Para que o código de convite funcione, o Domo também guarda um registro que
liga o código à casa, com o **nome da casa**. Qualquer pessoa com conta no Domo
que digite um código válido consegue ver o nome daquela casa.

### 3.3 Itens da despensa e lista de compras

Digitados pelos membros da casa e visíveis para todos os membros **ativos**
(quem ainda está pendente não vê):

- nome do item e categoria;
- situação (tem, em falta, no carrinho);
- se o item tem controle de quantidade: quantidade e estoque mínimo;
- data da última mudança de situação e **qual membro fez essa mudança** (pelo
  UID).

**Atenção aos campos de texto livre.** O nome da casa e o nome dos itens aceitam
qualquer texto e ficam visíveis para os outros membros. Não escreva ali
informações pessoais (nomes de pessoas, endereço, dados de saúde, como nome de
remédio, etc.) além do necessário para a casa se organizar.

### 3.4 Dados técnicos

- **Sessão de login**: guardada no seu aparelho (no aplicativo web, no
  armazenamento local do navegador) para você não precisar entrar a cada vez.
  Não é cookie de publicidade.
- **Foto de perfil**: é carregada diretamente dos servidores do Google e guardada
  em cache no seu aparelho.
- **Registros técnicos do Google**: ao usar o app, o seu endereço IP e dados
  básicos de cada requisição chegam à infraestrutura do Google Firebase, que os
  registra para operação e segurança do serviço.
- **Fontes**: ao abrir o app, as fontes são baixadas do Google Fonts, o que envia
  o seu endereço IP ao Google.

### 3.5 O que fica só no seu aparelho

A sua escolha sobre a medição de uso (seção 3.6) e as escolhas de tema
(claro/escuro) e de idioma não são enviadas a nenhum servidor.
`TODO: confirmar` — hoje o tema e o idioma nem são guardados entre aberturas do
app; se passarem a ser guardados, continuam só no aparelho.

### 3.6 Dados de uso (medição do aplicativo)

O Domo usa o **Google Analytics para Firebase** para entender, de forma
agregada, se as pessoas conseguem usar o app e voltam a usá-lo, e assim decidir
o que melhorar. A medição coleta:

- **Identificador de instância do app**: código gerado pelo Firebase, ligado à
  instalação do app naquele aparelho ou navegador, não à sua identidade.
- **Localização aproximada**: país e, no máximo, região/estado, deduzidos do
  endereço IP. **Não** é GPS.
- **Aparelho e versão**: modelo, sistema operacional, versão do Domo, idioma.
- **Uso automático**: telas abertas, sessões, primeira abertura.
- **Seis eventos do próprio Domo**, que registram só que a ação aconteceu, com
  no máximo uma contagem ou uma situação: casa criada; pedido para entrar em
  casa; mudança de situação de item (de qual para qual situação); carrinho
  fechado (quantos itens); quantidade de item atualizada (situação resultante);
  ordem de categorias alterada (quantas categorias).

O que **não** entra na medição: o seu nome, o seu e-mail, o seu UID, o nome da
casa, o código de convite, o nome dos itens ou das categorias.

- **Identificador de publicidade (Advertising ID)**: o app Android **não**
  coleta o identificador de publicidade (a permissão foi removida do app e a
  coleta foi desligada no Analytics), e a personalização por "sinais do Google"
  também fica desligada.
- **No aplicativo web**, a medição usa cookies e armazenamento local do
  navegador do Google Analytics. Não há banner de bloqueio prévio: a medição é
  feita com base no legítimo interesse (seção 5) e você pode desligá-la a
  qualquer momento em Perfil → Privacidade → Medição de uso.
- Esses dados **não** são usados para anúncios, não são combinados com dados de
  outros apps ou sites e não são vendidos. `TODO: confirmar` no console do
  Google Analytics: "sinais do Google" desligado e configurações de
  compartilhamento de dados desligadas.
- Você pode desligar essa medição dentro do aplicativo, em Perfil →
  Privacidade → Medição de uso, a qualquer momento e sem perder nenhuma função.
  A escolha vale na hora e fica guardada só no seu aparelho ou navegador. Se
  você limpar os dados do app ou do navegador, a medição volta ao padrão
  (ligada) e é preciso desligar de novo.

### 3.7 O que NÃO é coletado

Por decisão de projeto, o Domo **não** coleta e **não** pede:

- CPF, RG ou qualquer documento;
- telefone ou endereço;
- dados de pagamento, cartão ou conta bancária (o Domo não vende nada e não
  faz compras);
- localização por GPS, contatos da agenda, câmera, microfone ou arquivos do
  aparelho;
- dados de saúde ou outros dados pessoais sensíveis (a não ser que alguém os
  escreva nos campos de texto livre, o que recomendamos não fazer).

Fora o Google Analytics para Firebase (seção 3.6), o aplicativo **não contém
SDK de publicidade nem de rastreamento de terceiros** e não exibe anúncios.

### 3.8 Site de apresentação (`domo.cafelabs.net`)

O site de apresentação é só informativo: não tem login, cadastro nem
formulário, e a demonstração interativa roda inteiramente no seu navegador, sem
enviar nada. Ele usa uma medição de audiência agregada (Vercel Web Analytics)
que **não usa cookies**, não cria identificador persistente e não permite
identificar quem visitou. São registrados apenas dados agregados, como página
visitada, país aproximado, tipo de aparelho e navegador. Por isso não é exibido
banner de cookies no site. `TODO: confirmar` que não há outro script de medição
na landing no momento da publicação.

## 4. Para que os dados são usados

| Finalidade | Dados envolvidos |
|---|---|
| Criar e manter a sua conta e reconhecer você no login | e-mail, senha, dados da conta Google (se usada), UID |
| Criar casas, convidar e aprovar membros, mostrar quem está na casa | dados da casa e dos membros (3.2) |
| Comprovar que você aceitou os Termos e a Política | registro de aceite (3.1) |
| Guardar a despensa e a lista de compras e sincronizá-las entre os aparelhos dos membros | itens (3.3) |
| Impedir que uma pessoa acesse casas das quais não faz parte | UID, situação de membro, regras de segurança do Firestore |
| Manter o serviço funcionando e seguro (corrigir falhas, prevenir abuso) | dados técnicos (3.4), IP |
| Responder quando você pedir suporte ou exercer um direito | e-mail |
| Entender de forma agregada se o app é usado, para decidir o que melhorar | dados de uso (3.6) |
| Medir audiência do site de apresentação, de forma agregada | dados agregados (3.8) |

Os dados **não** são usados para propaganda, venda, perfilamento comercial ou
compartilhamento com lojas, supermercados, marcas ou qualquer terceiro
comercial.

**O Domo não envia mensagens promocionais.** Hoje o único e-mail que você pode
receber é transacional (por exemplo, redefinição de senha, se existir, ou
resposta a um pedido seu). Se um dia a Café Labs quiser enviar novidades ou
qualquer comunicação promocional, isso exigirá um **consentimento separado e
específico**, pedido numa caixa própria (nunca embutido na aceitação dos
Termos), que você poderá recusar ou retirar a qualquer momento **sem perder o
acesso ao aplicativo**.

## 5. Base legal de cada tratamento

| Tratamento | Base legal (Lei 13.709/2018 — LGPD) |
|---|---|
| Conta (e-mail, senha, dados da conta Google, UID) | art. 7º, V — execução de contrato do qual você é parte (os Termos de Uso) |
| Dados da casa e dos membros, inclusive mostrar o seu nome e a sua foto aos membros | art. 7º, V — execução de contrato: dividir a casa com outras pessoas é a função do app |
| Registro de aceite dos Termos e da Política | art. 7º, VI — exercício regular de direitos (comprovar o aceite, se necessário) |
| Itens da despensa e lista de compras | art. 7º, V — execução de contrato |
| Controle de acesso e proteção contra uso indevido | art. 7º, V, e art. 7º, IX — legítimo interesse na segurança do serviço |
| Registros técnicos (IP, logs do Firebase) | art. 7º, IX — legítimo interesse na operação e segurança |
| Atendimento a pedidos de titular | art. 7º, II — cumprimento de obrigação legal |
| Medição de uso do aplicativo (3.6) | art. 7º, IX — legítimo interesse na melhoria do produto, sem uso publicitário e com opção de desligar no app, inclusive na versão web (cookies). `TODO: confirmar` com o advogado se, no app web, a base deve ser consentimento |
| Medição agregada do site de apresentação | art. 7º, IX — legítimo interesse, sem identificação individual |
| Comunicação promocional (não existe hoje) | art. 7º, I — consentimento específico e destacado, se um dia existir |

Recusar comunicação promocional **não** limita nada no aplicativo.

## 6. Onde os dados ficam e transferência internacional

A sua conta e os dados das casas ficam no **Google Firebase** (Firebase
Authentication e Cloud Firestore), no projeto `domo-cafelabs`.

O banco Cloud Firestore fica na região `southamerica-east1` (São Paulo), então
**os dados das casas ficam armazenados em território nacional**. O Google, como
operador, pode acessá-los a partir de outros países exclusivamente para suporte
e operação da infraestrutura.

O Firebase Authentication e o Google Analytics para Firebase operam na
infraestrutura global do Google, independentemente da região do Firestore: **os
dados da sua conta e os dados de uso trafegam e podem ser armazenados fora do
Brasil.**

Essas transferências internacionais se apoiam no art. 33, II, da LGPD
(cláusulas contratuais de proteção de dados do Google Cloud / Firebase, "Cloud
Data Processing Addendum"). `TODO: confirmar` com o advogado a redação à luz da
Resolução CD/ANPD nº 19/2024 (cláusulas-padrão contratuais da ANPD) e se o
contrato do Google já as incorpora.

O site de apresentação é hospedado na Vercel, com servidores fora do Brasil, mas
não recebe dados da sua conta; só a medição agregada e não identificável da
seção 3.8 sai do país por ali.

## 7. Por quanto tempo os dados ficam guardados

| Dado | Prazo |
|---|---|
| Conta | enquanto a conta existir; você decide, não há expiração automática |
| Seus dados de membro numa casa | enquanto você for membro; saem da casa quando você sai, é removido pelo criador ou exclui a conta |
| Registro de aceite e lista de pedidos pendentes (3.1) | enquanto a conta existir; apagados na exclusão da conta |
| Casa e itens | enquanto a casa existir; são apagados quando o criador exclui a casa |
| Registro de "quem mudou por último" num item | fica no item enquanto a casa existir; depois que a sua conta é excluída, o código (UID) que fica ali não pode mais ser ligado a você, nem pela Café Labs. `TODO: confirmar` com o advogado se isso basta ou se o app deve apagar esse campo na exclusão (hoje o app não apaga) |
| Conta inativa | não há exclusão automática por inatividade hoje; se isso mudar, você será avisado por e-mail com antecedência mínima de 30 dias |
| Cópias de segurança manuais feitas pela Café Labs antes de atualizações do sistema | `TODO: confirmar` prazo. Hoje o procedimento de atualização manda copiar os dados das casas antes de mudanças, mas não define quando essa cópia é apagada. Sugestão: apagar em até 30 dias |
| Cópias internas da infraestrutura do Google | conforme o ciclo de exclusão do provedor. `TODO: confirmar` o prazo a declarar (o Dindin declarou "até 30 dias"; conferir na documentação do Google Cloud/Firebase) |
| Registros técnicos de operação e segurança | conforme a retenção do Google Firebase |
| Dados de uso do aplicativo (3.6) | `TODO: confirmar` no console do Google Analytics (sugestão: 2 meses, o mínimo); relatórios agregados sem prazo |

O Domo não está sujeito a nenhum prazo legal de guarda desses dados e pode
atender integralmente a um pedido de exclusão.

## 8. Seus direitos e como exercê-los

Pela LGPD (art. 18), você pode a qualquer momento:

- **Saber** se existem dados seus e quais são;
- **Acessar** os seus dados: tudo o que o Domo guarda sobre você aparece nas
  telas do app (perfil, casa, despensa); se quiser uma cópia, peça pelo e-mail
  abaixo;
- **Corrigir** dados: itens e situações você mesmo edita no app; a foto vem da
  sua conta Google e é corrigida lá. `TODO: confirmar` — hoje o nome exibido
  fica como foi digitado no cadastro, e o app ainda não tem tela para trocá-lo
  (pode ser pedido pelo e-mail abaixo);
- **Pedir a exclusão** da sua conta e dos seus dados (ver abaixo);
- **Pedir a portabilidade**: o Domo ainda não tem exportação dentro do app;
  enviamos uma cópia dos seus dados e da sua casa em formato aberto e legível
  (JSON) a pedido, pelo e-mail abaixo;
- **Saber com quem** os seus dados são compartilhados (seção 2);
- **Revogar** qualquer consentimento que você tenha dado separadamente;
- **Se opor** a um tratamento que considere irregular, inclusive desligar a
  medição de uso no próprio app (seção 3.6);
- **Reclamar** à ANPD (Autoridade Nacional de Proteção de Dados).

**Como pedir:** o que o app permite fazer sozinho (excluir a conta, desligar a
medição de uso) você faz direto nele; o restante, escreva para
`privacidade@cafelabs.net`. A resposta é dada em até **15 dias**.

### Exclusão da conta: o que acontece na prática

1. Você pede a exclusão dentro do aplicativo (Perfil → Excluir conta), pela
   página pública `https://domo.cafelabs.net/excluir-conta` ou pelo e-mail
   `privacidade@cafelabs.net`. No aplicativo, por segurança, o Domo pede que
   você confirme a senha (ou entre de novo com o Google) antes de excluir.
2. São eliminados: a sua conta de login (Firebase Authentication), os seus dados
   de membro (nome e foto) em todas as casas de que você participa, os seus
   pedidos de entrada ainda pendentes e os registros privados da seção 3.1.
3. **Casas que você criou: a casa e todos os itens são apagados para todos os
   membros.** O app avisa isso antes de você confirmar. Transferir a casa para
   outro membro ainda não existe; se não quiser que a casa acabe, não exclua a
   conta antes de combinar com os outros membros.
4. **Casas das quais você participa sem tê-las criado:** você sai da casa; os
   itens que você cadastrou continuam lá, porque são a lista compartilhada da
   casa, e o único vestígio é um código interno que não identifica você.
5. Cópias de segurança expiram no prazo da seção 7 e não são restauradas.

A exclusão é **definitiva e não reversível**.

## 9. Crianças e adolescentes

O Domo é um aplicativo de organização da casa e **pode ser usado por
adolescentes a partir de 13 anos**, por exemplo numa casa com a família. O
cadastro é **vedado a menores de 13 anos**. Ao criar a conta, você declara ter
13 anos ou mais. `TODO: confirmar` com o advogado a idade mínima e o tratamento
de dados de adolescentes (a LGPD, art. 14, trata crianças até 12 anos
incompletos com consentimento de pai, mãe ou responsável).

- **Menores de 13 anos:** o Domo não é destinado a eles e **não coleta o
  consentimento** que a lei exige para crianças. Se tomarmos conhecimento de
  que uma conta pertence a alguém com menos de 13 anos, ela será excluída.
- **De 13 a 17 anos:** o tratamento é feito no melhor interesse do adolescente
  (LGPD, art. 14, caput). O Domo só trata o necessário para o app funcionar
  (nome, e-mail, foto da conta Google, itens da casa), não pede dado a mais por
  causa da idade, e o responsável legal pode pedir a exclusão da conta pelo
  canal da seção 8. Recomendamos que um responsável acompanhe o uso e a escolha
  do que é escrito nos campos de texto livre.

Em nenhuma hipótese dados de crianças ou adolescentes são usados para
publicidade ou repassados a terceiros. O Domo não exibe anúncios.

## 10. Segurança

- Todo o tráfego é criptografado em trânsito (HTTPS/TLS).
- Os dados em repouso são criptografados pela infraestrutura do Google
  Firebase.
- O acesso aos dados é controlado pelo servidor, por meio das *Security Rules*
  do Firestore: só membros de uma casa leem os dados dela, só membros ativos
  leem e editam os itens, e só quem criou a casa aprova, remove membros ou a
  exclui. Essas regras são testadas automaticamente a cada alteração.
- A senha é guardada e verificada pelo Google, cifrada, e não é legível pela
  Café Labs.
- O acesso administrativo à infraestrutura é individual e restrito.

Nenhum sistema é 100% seguro. Se ocorrer um incidente de segurança que possa
gerar risco ou dano relevante a você, a Café Labs comunicará a **ANPD** e
**você** nos termos do art. 48 da LGPD, dentro do prazo da regulamentação da
ANPD (hoje, **3 dias úteis** a partir do conhecimento do incidente, Resolução
CD/ANPD nº 15/2024), informando o que aconteceu, quais dados foram afetados,
quais os riscos e o que está sendo feito.

**Proteja a sua senha e o código da sua casa.** A Café Labs nunca vai pedir a sua
senha por e-mail, mensagem ou telefone.

## 11. Alterações desta política

Se esta política mudar de forma relevante, a nova versão será publicada no
mesmo endereço com a data de vigência, e você será avisado dentro do aplicativo
antes de continuar usando. As versões anteriores ficam arquivadas.

## 12. Contato

Café Labs — Felipe Portes Antunes
E-mail: `privacidade@cafelabs.net`

Autoridade Nacional de Proteção de Dados (ANPD): https://www.gov.br/anpd

---

> **Aviso de elaboração (remover só depois da revisão):** este texto é um
> rascunho gerado com apoio de IA a partir do código do app. Ele **não foi
> revisado por advogado(a)** e não deve ser publicado nem tratado como
> proteção jurídica até essa revisão.
