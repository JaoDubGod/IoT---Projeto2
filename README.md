# Estufa inteligente integrada ao FIWARE

**Disciplina:** CCM520 - Internet das Coisas  
**Integrante:** João Pedro Spiezzi Monti, RA 22.125.049-1  
**Wokwi:** circuito em documentacao_apoio/circuito-wokwi.png; URL do projeto não recebida.

## 1. Visão geral

A ESP32 irá ler a temperatura e umidade do ar no DHT22, umidade do solo e luminosidade por entradas ADC. Publicará leituras e estados por MQTT. Já o IoT Agent JSON converte as mensagens em atributos NGSI-v2 no Orion. Os comandos do Orion acionam o relé e o servomotor. O Cygnus grava as mudanças no MySQL. E o Grafana consulta o histórico, finalizando com o consumidor recebe alerta de solo seco.

## 2. Arquitetura

ESP32/Wokwi -> MQTT TCP 1883 -> broker.hivemq.com <-> ponte Mosquitto local :1883 <-> IoT Agent JSON -> NGSI-v2 HTTP 1026 -> Orion -> HTTP 5050 -> Cygnus -> MySQL TCP 3306 -> Grafana HTTP 3000.
Orion -> notificação HTTP interna -> consumidor :3000 (publicado no host em localhost:3001).

A ponte traz as medidas e os resultados da API key do projeto para o broker local e leva os comandos locais ao tópico público da ESP32. O IoT Agent fica no broker local.

## 3. Hardware e pinos

| Componente | GPIO | Leitura/controle |
|---|---:|---|
| DHT22 | 4 | temperatura e umidade relativa |
| Sensor de solo | 34 | ADC1, saída analógica |
| LDR/divisor | 35 | ADC1, ponto médio |
| Relé | 26 | saída digital 0/1 |
| Servomotor | 27 | PWM a 50 Hz |

GPIO34 e GPIO35 são entradas ADC. Confirme VCC dos sensores e GND comum. A captura recebida aparenta deixar VCC do DHT22 e dos módulos analógicos sem ligação.

**Calibração atual:** conversão linear invertida do ADC de 12 bits: 4095 -> 0% e 0 -> 100%. É hipótese inicial para a simulação, não uma calibração medida. Verifique os extremos seco/molhado e escuro/claro no Wokwi antes de interpretar porcentagens como grandezas reais.

## 4. Identificadores

| Item | Valor |
|---|---|
| API key MQTT | jpmonti62026 |
| Client ID da ponte | ponte_jpmonti62026 |
| Client ID da ESP32 | esp32_jpmonti62026_estufajpmonti01 |
| fiware-service | fei |
| fiware-servicepath | /estufajpmonti |
| device_id | estufajpmonti01 |
| Entidade | urn:ngsi-ld:Greenhouse:estufajpmonti01 |
| Tipo / recurso | Greenhouse / /iot/json |
| Tabela do Cygnus | estufajpmonti |

A API key difere das chaves dos exemplos recebidos. Confirme que é única na turma. Ela separa tópicos no broker público, mas não autentica o dispositivo.

## 5. Modelo de dados e comandos

| object_id | Atributo NGSI | Tipo | Unidade/faixa |
|---|---|---|---|
| t | temperature | Number | °C |
| h | relativeHumidity | Number | % |
| s | soilMoisture | Number | 0-100% |
| l | illuminance | Number | 0-100% relativo |
| r | relayState | Number | 0 ou 1 |
| a | windowAngle | Number | 0-180° |
| i | samplingInterval | Number | segundos |

O firmware publica um JSON com os sete campos. Intervalo inicial: 3 s. setInterval aceita 2-10 s.
O provisionamento também inclui os atributos estáticos name e location; a coordenada GeoJSON é apenas demonstrativa, não uma medição da instalação.

| Comando | Valores aceitos | Resposta |
|---|---|---|
| setRelay | 0 ou 1 | OK; ERRO fora da faixa |
| setServo | inteiro de 0 a 180 | OK; ERRO fora da faixa |
| setInterval | inteiro de 2 a 10 s | OK; ERRO fora da faixa |
| setSending | 0 ou 1 | OK; comandos continuam sendo recebidos quando 0 |

| Fluxo | Tópico |
|---|---|
| Medidas | /json/jpmonti62026/estufajpmonti01/attrs |
| Comandos | /jpmonti62026/estufajpmonti01/cmd |
| Resultado | /json/jpmonti62026/estufajpmonti01/cmdexe |

Medidas e cmdexe atravessam a ponte na direção in (público -> local); cmd usa out (local -> público).

## 6. Como reproduzir

O roteiro completo, incluindo o significado dos JSONs e credenciais do MySQL/Grafana, está em [GUIA-DO-ZERO.md](GUIA-DO-ZERO.md).

1. Instale Docker Desktop. Na pasta plataforma, copie .env.example para .env e ajuste as credenciais locais. .env é ignorado pelo Git.
2. Execute docker compose pull e docker compose up -d. Confira docker compose ps e aguarde os serviços ficarem healthy.
3. Importe postman/Projeto 2.postman_collection.json. Rode Etapa 1; use a pasta de limpeza só se já houver dados de um provisionamento anterior que deseja remover; depois rode Etapa 2.
4. Confira a alimentação no Wokwi, grave firmware/main_esqueleto.py como main.py, use Wokwi-GUEST com senha vazia e inicie a simulação.
5. Rode as etapas de medidas e comandos. Confira entidade e resposta no Orion.
6. Crie a fonte MySQL no Grafana: host mysql-db:3306, banco fei, usuário grafana e senha definida no SQL. Importe plataforma/painel-estufa.json e associe a fonte. Atualização: 5 s.
7. Rode Etapa 4 no Postman para verificar subscrições, histórico e painel.

Para encerrar use docker compose down. Para apagar dados e reiniciar, use docker compose down -v.

## 7. Subscrições

| Subscrição | Condição | Destino | Atributos/formato |
|---|---|---|---|
| Histórico | entidades Greenhouse | http://cygnus:5050/notify | sete medidas, normalized |
| Alerta | soilMoisture < 30 | http://consumidor:3000/alerta-estufa | soilMoisture, relayState, TimeInstant; keyValues |

## 8. Painel

O JSON define temperatura e umidade do ar, umidade do solo, linha do tempo do relé e luminosidade atual. Consulta a tabela estufajpmonti, derivada do service path /estufajpmonti. Acrescente uma captura real do Grafana após executar a stack.

## 9. Estado de validação

O projeto foi validado após a inicialização, e a execução ocorreu como esperado. As páginas da plataforma carregaram corretamente.

## 10. Decisões e limitações

O firmware valida valores antes de alterar atuadores, responde no tópico cmdexe com uma chave igual ao nome do comando e mantém a escuta MQTT quando o envio de medidas está desligado. A reconexão MQTT está representada no código enviado.

Solo e luminosidade usam escala linear invertida, ainda sujeita à calibração. O estado do relé é o último valor comandado, sem sensor de retorno da carga. O broker público não fornece autenticação, ACL ou criptografia. A stack é de laboratório, não de produção.

## 11. Desafios opcionais

D.2 (reconexão MQTT) está implementado no firmware; o comportamento após uma queda de conexão não foi detalhado nesta validação. D.1 (malha fechada), D.3 (TLS) e D.4 (segunda estufa) não estão implementados.

## 12. Uso de ferramentas de IA

Codex da OpenIA foi usado, a pedido do professor que testa o material, para organizar arquivos, personalizar identificadores e preparar README, painel JSON e rascunho de relatório. O firmware base e o circuito vieram do material enviado pelo usuário. A integração não foi executada.

## 13. Referências

- CCM520. Projeto 2 - Estufa inteligente na plataforma FIWARE. Apresentação fornecida pelo professor, 2026.
- CCM520. Projeto 2 - Guia passo a passo. Material fornecido pelo professor, 2026.
- CCM520. Material de apoio do Projeto 2. Arquivo do ZIP complementar.
- Documentação do FIWARE IoT Agent JSON e Orion NGSI-v2, conforme referências indicadas no material da disciplina.
