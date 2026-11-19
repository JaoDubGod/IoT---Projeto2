# Corpos preenchidos nas quatro requisições Postman

Esses JSONs já estão inseridos nas quatro requisições [Complete o corpo] da coleção incluída. Use como referência se importar a coleção original novamente. Preserve método, URL e cabeçalhos; `fiware-service=fei` e `fiware-servicepath=/estufa`. A API key deve coincidir com firmware e ponte.

## 2.1 Grupo — POST /iot/groups

```json
{
  "services": [{
    "apikey": "{{apikey}}",
    "entity_type": "Greenhouse",
    "resource": "/iot/json",
    "attributes": [],
    "lazy": [],
    "commands": [],
    "cbroker": "http://orion:1026",
    "autoprovision": false
  }]
}
```

## 2.2 Dispositivo — POST /iot/devices

```json
{
  "devices": [{
    "device_id": "{{device_id}}",
    "entity_name": "{{entidade}}",
    "entity_type": "Greenhouse",
    "protocol": "IoTA-JSON",
    "transport": "MQTT",
    "apikey": "{{apikey}}",
    "attributes": [
      {"object_id":"t","name":"temperature","type":"Number"},
      {"object_id":"h","name":"relativeHumidity","type":"Number"},
      {"object_id":"s","name":"soilMoisture","type":"Number"},
      {"object_id":"l","name":"illuminance","type":"Number"},
      {"object_id":"r","name":"relayState","type":"Number"},
      {"object_id":"w","name":"windowAngle","type":"Number"},
      {"object_id":"i","name":"samplingInterval","type":"Number"}
    ],
    "commands": [
      {"name":"setRelay","type":"command"},
      {"name":"setServo","type":"command"},
      {"name":"setInterval","type":"command"},
      {"name":"setSending","type":"command"}
    ],
    "static_attributes": [
      {"name":"name","type":"Text","value":"Estufa inteligente"},
      {"name":"location","type":"geo:json","value":{"type":"Point","coordinates":[-46.56,-23.64]}}
    ]
  }]
}
```

As coordenadas são um exemplo (longitude, latitude); altere para as do grupo. Se o IoT Agent da imagem rejeitar `protocol`, compare com o dispositivo da lâmpada da coleção e retire somente o campo não aceito.

## 4.1 Histórico Cygnus — POST /v2/subscriptions

```json
{
  "description":"Historico da estufa",
  "subject":{"entities":[{"id":"{{entidade}}","type":"Greenhouse"}],"condition":{"attrs":["temperature","relativeHumidity","soilMoisture","illuminance","relayState","windowAngle","samplingInterval"]}},
  "notification":{"http":{"url":"http://cygnus:5050/notify"},"attrs":["temperature","relativeHumidity","soilMoisture","illuminance","relayState","windowAngle","samplingInterval"],"attrsFormat":"normalized"},
  "throttling":1
}
```

## 4.4 Alerta de solo — POST /v2/subscriptions

```json
{
  "description":"Alerta de solo seco da estufa",
  "subject":{"entities":[{"id":"{{entidade}}","type":"Greenhouse"}],"condition":{"attrs":["soilMoisture"],"expression":{"q":"soilMoisture<30"}}},
  "notification":{"http":{"url":"http://consumidor:3000/alerta-estufa"},"attrs":["soilMoisture","relayState","TimeInstant"],"attrsFormat":"keyValues"},
  "throttling":60
}
```
