# Coleções Postman

- Projeto 2.postman_collection.json: coleção da estufa deste projeto; os quatro corpos solicitados estão preenchidos.
- Exemplo - Lâmpada.postman_collection.json: demonstração local opcional do material do curso, com identificador local alterado.

Importe a coleção do Projeto 2. As variáveis de API key, device_id, entidade, service path e Grafana foram ajustadas para este projeto. `grafana_usuario`/`grafana_senha` são o login da API Web do Grafana e devem coincidir com `GRAFANA_ADMIN_USER`/`GRAFANA_ADMIN_PASSWORD` no `plataforma/.env`.

O usuário e senha da fonte de dados MySQL são diferentes: usuário `grafana`, senha definida em `plataforma/mysql/01-usuario-grafana.sql`. Esse usuário tem apenas permissão `SELECT` no banco `fei`.

Rode as pastas na ordem apresentada. A pasta 0 remove provisionamento e subscrições anteriores da chave. A Etapa 3 requer o firmware conectado; a Etapa 4 requer histórico gravado e o painel importado. Nenhum resultado do Runner foi gerado nesta montagem estática.
