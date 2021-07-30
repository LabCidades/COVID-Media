# Data Dictionary

| Original Question                                                                                                                                                      | Coded Question | Likert |
|------------------------------------------------------------------------------------------------------------------------------------------------------------------------|----------------|--------|
| Timestamp                                                                                                                                                              | `timestamp`      | time   |
| Qual seu gênero?                                                                                                                                                       | `sex`            | open   |
| Onde você more atualmente?                                                                                                                                             | `location`       | open   |
| Qual a sua idade?                                                                                                                                                      | `age`            | open   |
| Qual sua escolaridade?                                                                                                                                                 | `education`      | open   |
| Qual seu estado civil?                                                                                                                                                 | `marriage`       | open   |
| Atualmente como se enquadra o seu status empregatício?                                                                                                                 | `employment`     | open   |
| Em qual faixa de renda mensal você se enquadra?                                                                                                                        | `income`         | open   |
| Por favor, indique se possui qualquer uma das condições médicas abaixo?                                                                                                | `diaoth`         | open   |
| Você já foi diagnosticado com COVID-19                                                                                                                                 | `diacov`         | binary |
| Você está com sintomas de outra doença que não seja COVID-19?                                                                                                          | `diasympoth`     | binary |
| Você tem permanecido em casa e em isolamento social?                                                                                                                   | `isolation`      | binary |
| O quanto você está com medo de contrair o Coronavírus?                                                                                                                 | `afra1`          | 4      |
| O quanto você está com medo de que algum familiar próximo contraia o Coronavírus?                                                                                      | `afra2`          | 4      |
| Quanto tempo por dia você gasta normalmente checando as notícias sobre COVID-19?                                                                                       | `hmtime`         | 4      |
| Quais são os tipos de informações que mais lhe interessam sobre o COVID-19?                                                                                            | `interest`       | open   |
| Quando busca informações sobre COVID-19, qual a frequência que você usa as seguintes fontes? [Jornal]                                                                  | `fnp`            | 5      |
| Quando busca informações sobre COVID-19, qual a frequência que você usa as seguintes fontes? [Televisão]                                                               | `ftv`            | 5      |
| Quando busca informações sobre COVID-19, qual a frequência que você usa as seguintes fontes? [Rádio]                                                                   | `fra`            | 5      |
| Quando busca informações sobre COVID-19, qual a frequência que você usa as seguintes fontes? [Sites da Internet]                                                       | `fws`            | 5      |
| Quando busca informações sobre COVID-19, qual a frequência que você usa as seguintes fontes? [Redes Sociais (Facebook, Twitter)]                                       | `fsm`            | 5      |
| Quando busca informações sobre COVID-19, qual a frequência que você usa as seguintes fontes? [Comunicação com Profissionais de Saúde (Médicos(as), Enfermeiros(as))]   | `fmp`            | 5      |
| Se você recebesse mensagens de textos sobre informações sobre COVID-19, como preferiria?                                                                               | `text`           | open   |
| Se você recebesse vídeos sobre informações sobre COVID-19, como preferiria?                                                                                            | `videa`          | open   |
| Se usa outros meios de comunicação para consumir informações de COVID-19, por favor especifique abaixo                                                                 | `mediaother`     | open   |
| Uso de Redes Sociais [Você já postou um comentário ou uma pergunta em uma discussão online ou grupo online?]                                                           | `comment_3`      | binary |
| Uso de Redes Sociais [Você já postou um comentário ou uma pergunta em um blog?]                                                                                        | `comment_4`      | binary |
| Uso de Redes Sociais [Você já postou um comentário ou uma pergunta no Facebook ou LinkedIn?]                                                                           | `comment_5`      | binary |
| Uso de Redes Sociais [Você já postou um comentário ou uma pergunta no Twitter?]                                                                                        | `comment_1`      | binary |
| Uso de Redes Sociais [Você já postou um comentário ou uma pergunta em site de qualquer natureza como sites de saúde e bem-estar?]                                      | `comment_6`      | binary |
| Uso de Redes Sociais [Você já postou um comentário ou uma pergunta no YouTube?]                                                                                        | `comment_2`      | binary |
| Crenças de saúde antes da exposição [Você acredita que está em alto risco de ficar doente com COVID-19?]                                                               | `hb_b_psu`       | 5      |
| Crenças de saúde antes da exposição [Você acredita que se ficar doente de COVID-19, a doença será severa?]                                                             | `hb_b_pse`       | 5      |
| Crenças de saúde antes da exposição [Você acredita que comportamentos saudáveis podem lhe proteger de ficar doente de COVID-19?]                                       | `hb_b_pbe`       | 5      |
| Crenças de saúde antes da exposição [Você acredita que é difícil manter comportamentos saudáveis que protegem contra o risco de ficar doente de COVID-19?]             | `hb_b_pba`       | 5      |
| Crenças de saúde antes da exposição [Você se sente seguro em manter comportamentos saudáveis?]                                                                         | `hb_b_se`        | 5      |
| Crenças de saúde depois da exposição [Você acredita que é suscetível a ser infectado pelo COVID-19 depois de receber informações dos veículos de comunicação?]         | `hb_a_psu`       | 5      |
| Crenças de saúde depois da exposição [Você acredita que contrair COVID-19 é um risco severo para sua sáude após ler informações dos veículos de comunicação?]          | `hb_a_pse`       | 5      |
| Crenças de saúde depois da exposição [Você acredita que comportamento saudáveis podem ajudá-lo a se manter saudável após ler informações dos veículos de comunicação?] | `hb_a_pbe`       | 5      |
| Crenças de saúde depois da exposição [Você sente que é difícil aderir à dicas saudáveis durante a pandemia?]                                                           | `hb_a_pba`       | 5      |
| Crenças de saúde depois da exposição [Você acredita que consegue manter hábitos saudáveis durante a pandemia?]                                                         | `hb_a_se`        | 5      |
| Você tomou quaisquer medidas para reduzir o seu risco de contrair COVID-19?                                                                                            | `action`         | binary |
| O quão frequente você realizou as seguintes ações durante a pandemia? [Evitou locais onde é sabido que há transmissões de COVID-19?]                                   | `be_01`          | 5      |
| O quão frequente você realizou as seguintes ações durante a pandemia? [Lavou suas mãos com água e sabão ou com álcool em gel?]                                         | `be_02`          | 5      |
| O quão frequente você realizou as seguintes ações durante a pandemia? [Evitou fazer contato com suas mãos em nariz, boca, e olhos?]                                    | `be_03`          | 5      |
| O quão frequente você realizou as seguintes ações durante a pandemia? [Proteger com o cotovelo ou um pano tosses e espirros?]                                          | `be_04`          | 5      |
| O quão frequente você realizou as seguintes ações durante a pandemia? [Jogou no lixo guardanapos ou lenços usados?]                                                    | `be_05`          | 5      |
| O quão frequente você realizou as seguintes ações durante a pandemia? [Você compartilha sua toalha de banho com outros?]                                               | `be_06`          | 5      |
| O quão frequente você realizou as seguintes ações durante a pandemia? [Você ventila seus cômodos e quartos?]                                                           | `be_07`          | 5      |
| O quão frequente você realizou as seguintes ações durante a pandemia? [Mantém no mínimo 1 metro de distância entre você e pessoas que estão tossindo ou espirrando?]   | `be_08`          | 5      |
| O quão frequente você realizou as seguintes ações durante a pandemia? [Evitou aperto de mãos ou outro contato físico?]                                                 | `be_09`          | 5      |
| O quão frequente você realizou as seguintes ações durante a pandemia? [Evitou usar utensílios comuns durante refeições?]                                               | `be_10`          | 5      |
| O quão frequente você realizou as seguintes ações durante a pandemia? [Evitou tocar, comprar ou comer produtos animais?]                                               | `be_11`          | 5      |
| O quão frequente você realizou as seguintes ações durante a pandemia? [Evitou visitar parentes ou amigos que não convivem com você?]                                   | `be_12`          | 5      |
| O quão frequente você realizou as seguintes ações durante a pandemia? [Não tocou objetos em público?]                                                                  | `be_13`          | 5      |
| O quão frequente você realizou as seguintes ações durante a pandemia? [Evitou ir para locais aglomerados ou com pouca ventilação?]                                     | `be_14`          | 5      |
| O quão frequente você realizou as seguintes ações durante a pandemia? [Evitou cuspir no chão?]                                                                         | `be_15`          | 5      |
| O quão frequente você realizou as seguintes ações durante a pandemia? [Comeu comidas saudáveis?]                                                                       | `be_16`          | 5      |
| O quão frequente você realizou as seguintes ações durante a pandemia? [Fez exercícios físicos?]                                                                        | `be_17`          | 5      |
| O quão frequente você realizou as seguintes ações durante a pandemia? [Usou termômetro, máscara facial ou higienizou sua residência?]                                  | `be_18`          | 5      |
| O quão frequente você realizou as seguintes ações durante a pandemia? [Colocou máscara facial quando saía da sua casa?]                                                | `be_19`          | 5      |
| O quão frequente você realizou as seguintes ações durante a pandemia? [Evitou transporte público?]                                                                     | `be_20`          | 5      |
| O quão confiante você está com relação à: [Habilidade do governo em lidar com a pandemia de COVID-19?]                                                                 | `confi_gov`      | 4      |
| O quão confiante você está com relação à: [Habilidade dos hospital em lidar com a pandemia de COVID-19?]                                                               | `confi_hos`      | 4      |
| O quão confiante você está com relação à: [Habilidade dos profissionais de saúde em lidar com a pandemia de COVID-19?]                                                 | `confi_wor`      | 4      |
| O quão confiante você está com relação à: [Habilidade dos veículos de comunicação em transmitir informações úteis sobre a pandemia de COVID-19?]                       | `confi_media`    | 4      |
