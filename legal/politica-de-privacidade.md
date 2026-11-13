# Política de Privacidade — Domo

**Versão 0.1 (RASCUNHO), 12 de novembro de 2026**
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
> - Trechos marcados `TODO: confirmar` dependem de decisão do Felipe ou de
>   conferência no console do Firebase. Trechos marcados `[A IMPLEMENTAR]`
>   descrevem funções que **ainda não existem no app** e não podem ir ao ar
>   como estão: ou a função é implementada antes da publicação, ou o trecho
>   é reescrito.
> - Documento separado dos Termos de Uso (`termos-de-uso.md`), de propósito.

---

## 1. Em linguagem simples

O Domo é um aplicativo para organizar a casa em grupo: uma despensa
compartilhada (o que tem, o que acabou, o que está no carrinho) e uma lista de
compras que sai dela. Você cria uma "casa" ou entra numa casa que já existe
usando um código de convite, e todos os membros veem e editam a mesma lista.

Para isso o Domo precisa de uma conta (e-mail, ou login com Google). **Os
membros da sua casa veem o seu nome, a sua foto e, se você entrou com e-mail e
senha, o seu e-mail.** É assim que eles sabem quem está na casa.

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

**Canal de contato sobre privacidade:** `privacidade@cafelabs.net`
(`TODO: confirmar` que o mesmo e-mail do Dindin atende o Domo).

A Café Labs é hoje um agente de tratamento de pequeno porte e, nos termos da
Resolução CD/ANPD nº 2/2022, está dispensada de indicar formalmente um(a)
Encarregado(a), mas mantém este canal de comunicação com você e com a ANPD,
como a mesma norma exige. Se o volume ou a natureza do tratamento mudar, a
indicação será feita e esta política será atualizada.

## 3. Quais dados são tratados

### 3.1 Dados da sua conta

Criados quando você se cadastra, e guardados pelo Firebase Authentication:

- **E-mail**: identificador de login.
- **Senha**: só se você se cadastrou com e-mail e senha. É guardada pelo Google
  de forma cifrada e **não é legível pela Café Labs**.
- **Nome e foto de perfil da conta Google**: só se você usar "Entrar com
  Google". Vêm da sua conta Google; o Domo não pede esses dados a você.
- **Identificador interno da conta (UID)**: código gerado pelo Firebase que
  liga você às casas de que participa.
- **Datas de criação da conta e do último acesso**, e o **endereço IP** usado no
  cadastro e no login, registrados pelo Firebase Authentication para segurança
  e prevenção de abuso.

### 3.2 Dados da casa e dos membros (visíveis para os outros membros)

Quando você cria uma casa ou entra numa, o Domo guarda no Cloud Firestore:

- **Da casa**: o nome que o criador deu, o código de convite de 6 caracteres,
  quem criou e quando, e a ordem escolhida para as categorias da despensa.
- **De cada membro, inclusive você**:
  - **nome exibido**: o nome da sua conta Google ou, **se você entrou com
    e-mail e senha, o seu próprio e-mail** (o Domo ainda não permite escolher um
    nome de exibição — `TODO: confirmar` se isso muda antes da publicação);
  - **link da foto de perfil** da conta Google, se houver;
  - **cargo** ("Administrador" ou "Membro", só um rótulo);
  - **situação**: ativo ou pendente (aguardando aprovação).

**Quem vê esses dados:** todos os membros da casa. **Atenção:** quem digita o
código de convite e pede para entrar passa a ver o nome da casa e a lista de
membros (nome, e-mail quando for o caso, foto e cargo) **já enquanto aguarda
aprovação**, mesmo que depois seja recusado. Por isso, compartilhe o código só
com quem você conhece. `TODO: confirmar` — ver nota de produto no relatório
(pode ser corrigido no app em vez de só avisado aqui).

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

A escolha de tema (claro/escuro) e de idioma não é enviada a nenhum servidor.
`TODO: confirmar` — hoje essas escolhas nem são guardadas entre aberturas do app;
se passarem a ser guardadas, continuam só no aparelho.

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

- **Identificador de publicidade (Advertising ID)**: `TODO: confirmar` — hoje o
  app Android **não desliga** essa coleta, que o SDK do Google Analytics faz por
  padrão. A recomendação é desligar antes de publicar (como no Dindin), e então
  este parágrafo diz: "a coleta do identificador de publicidade e os 'sinais do
  Google' ficam desligados". Se continuar ligada, este parágrafo precisa dizer
  que o identificador é coletado, e a declaração de Advertising ID na Play
  muda.
- **No aplicativo web**, a medição usa cookies e armazenamento local do
  navegador do Google Analytics. `TODO: confirmar` decisão sobre aviso/banner
  de cookies no app web (ver relatório).
- Esses dados **não** são usados para anúncios, não são combinados com dados de
  outros apps ou sites e não são vendidos. `TODO: confirmar` no console do
  Google Analytics: "sinais do Google" desligado e configurações de
  compartilhamento de dados desligadas.
- **[A IMPLEMENTAR]** Você pode desligar essa medição dentro do aplicativo, em
  Perfil → Privacidade, a qualquer momento e sem perder nenhuma função.

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
| Dados da casa e dos membros, inclusive mostrar o seu nome/e-mail/foto aos membros | art. 7º, V — execução de contrato: dividir a casa com outras pessoas é a função do app |
| Itens da despensa e lista de compras | art. 7º, V — execução de contrato |
| Controle de acesso e proteção contra uso indevido | art. 7º, V, e art. 7º, IX — legítimo interesse na segurança do serviço |
| Registros técnicos (IP, logs do Firebase) | art. 7º, IX — legítimo interesse na operação e segurança |
| Atendimento a pedidos de titular | art. 7º, II — cumprimento de obrigação legal |
| Medição de uso do aplicativo (3.6) | art. 7º, IX — legítimo interesse na melhoria do produto, sem uso publicitário e com opção de desligar no app **[A IMPLEMENTAR]** `TODO: confirmar` com o advogado se, no app web (cookies), a base deve ser consentimento |
| Medição agregada do site de apresentação | art. 7º, IX — legítimo interesse, sem identificação individual |
| Comunicação promocional (não existe hoje) | art. 7º, I — consentimento específico e destacado, se um dia existir |

Recusar comunicação promocional **não** limita nada no aplicativo.

## 6. Onde os dados ficam e transferência internacional

A sua conta e os dados das casas ficam no **Google Firebase** (Firebase
Authentication e Cloud Firestore), no projeto `domo-8b336`.

`TODO: confirmar` a região do banco Firestore do projeto `domo-8b336`
(Firebase Console → Firestore → região, imutável). Usar **um** dos dois textos:

- **Se a região for `southamerica-east1` (São Paulo):** "Os dados das casas
  ficam armazenados em território nacional. O Google, como operador, pode
  acessá-los a partir de outros países exclusivamente para suporte e operação
  da infraestrutura."
- **Se a região for outra (por exemplo `nam5` ou `us-central1`, Estados
  Unidos):** "Os dados das casas (nomes, e-mails e fotos dos membros, itens da
  despensa) **ficam armazenados nos Estados Unidos**, em servidores do Google."

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
| Casa e itens | enquanto a casa existir; são apagados quando o criador exclui a casa |
| Registro de "quem mudou por último" num item | fica no item enquanto a casa existir; depois que a sua conta é excluída, o código (UID) que fica ali não pode mais ser ligado a você, nem pela Café Labs. `TODO: confirmar` com o advogado se isso basta ou se o app deve apagar esse campo na exclusão |
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
- **Corrigir** dados: itens e situações você mesmo edita no app; o nome e a foto
  vêm da sua conta Google e são corrigidos lá. `TODO: confirmar` — hoje quem
  entra com e-mail não tem como trocar o nome exibido no app;
- **Pedir a exclusão** da sua conta e dos seus dados (ver abaixo);
- **Pedir a portabilidade**: o Domo ainda não tem exportação dentro do app;
  enviamos uma cópia dos seus dados e da sua casa em formato aberto e legível
  (JSON) a pedido, pelo e-mail abaixo;
- **Saber com quem** os seus dados são compartilhados (seção 2);
- **Revogar** qualquer consentimento que você tenha dado separadamente;
- **Se opor** a um tratamento que considere irregular, inclusive desligar a
  medição de uso (seção 3.6) **[A IMPLEMENTAR]**;
- **Reclamar** à ANPD (Autoridade Nacional de Proteção de Dados).

**Como pedir:** escreva para `privacidade@cafelabs.net`. A resposta é dada em
até **15 dias**.

### Exclusão da conta: o que acontece na prática

**[A IMPLEMENTAR]** — o Domo ainda não tem exclusão de conta. Texto proposto
para quando existir:

1. Você pede a exclusão dentro do aplicativo (Perfil → Excluir conta), pela
   página pública `TODO: confirmar URL` (sugestão:
   `https://domo.cafelabs.net/excluir-conta`) ou pelo e-mail
   `privacidade@cafelabs.net`.
2. São eliminados: a sua conta de login (Firebase Authentication) e os seus
   dados de membro (nome, e-mail, foto, cargo) em todas as casas de que você
   participa.
3. **Casas que você criou:** `TODO: confirmar` decisão. Opção recomendada no
   relatório: o app avisa quem são os outros membros e, ao confirmar, **a casa e
   todos os itens são apagados para todos**. (Alternativa: exigir que você
   exclua a casa antes; transferir a casa para outro membro ainda não existe.)
4. **Casas das quais você participa sem tê-las criado:** você sai da casa; os
   itens que você cadastrou continuam lá, porque são a lista compartilhada da
   casa, sem nenhum dado que identifique você.
5. Cópias de segurança expiram no prazo da seção 7 e não são restauradas.

A exclusão é **definitiva e não reversível**.

## 9. Crianças e adolescentes

`TODO: confirmar` — decisão do Felipe sobre a idade mínima (ver relatório). O
texto abaixo segue a opção conservadora, igual à do Dindin (só maiores de 18
anos criam conta). Como o Domo é um app de família, é realista que
adolescentes da casa queiram usar; se a decisão for aceitar 12 a 17 anos, este
item e o item 2 dos Termos precisam ser reescritos com o advogado.

O Domo **não é destinado a menores de 18 anos** e a Café Labs não direciona o
produto a crianças ou adolescentes.

- **Menores de 12 anos (crianças):** o tratamento de dados de criança exige
  consentimento específico e em destaque de pelo menos um dos pais ou do
  responsável legal (art. 14, §1º, da LGPD). O Domo **não coleta esse
  consentimento** e, portanto, **não deve ser usado por crianças**. Se tomarmos
  conhecimento de que uma conta pertence a uma criança, ela será excluída.
- **Entre 12 e 17 anos (adolescentes):** o tratamento, se ocorrer, é feito no
  melhor interesse do adolescente (art. 14, caput). Os Termos de Uso restringem
  o cadastro a maiores de 18 anos, e pai, mãe ou responsável pode pedir a
  exclusão da conta pelo canal da seção 8.

Em nenhuma hipótese dados de crianças ou adolescentes são usados para
publicidade ou repassados a terceiros.

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
