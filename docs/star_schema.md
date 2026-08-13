# Modelar star schema

Antes de qualquer código, vamos desenhar a estrutura.

`Star schema` é o padrão clássico de modelagem pra analytics: uma tabela fato no centro
(eventos/transações, com números que você soma/conta) 
cercada de `tabelas dimensão` (atributos descritivos pra filtrar e agrupar).


````
                   dim_customer
                   (customer_id)
                         │
                         │
dim_product ──────── fact_orders ──────── dim_seller
(product_id)      (order_id,             (seller_id)
                    order_item_id,
                    customer_id,
                    product_id,
                    seller_id,
                    price,
                    freight_value,
                    order_purchase_timestamp,
                    order_status)
                         │
                         │
                    dim_date
                (order_purchase_date)

````

## Diagrama


## Tabela Fato: `fact_orders`

Granularidade: **um item de pedido por linha** (mesma granularidade de `silver.order_items`).

| Coluna | Tipo | Origem |
|---|---|---|
| `order_id` | string | `silver.orders` |
| `order_item_id` | int | `silver.order_items` |
| `customer_id` | string | `silver.orders` (FK → dim_customer) |
| `product_id` | string | `silver.order_items` (FK → dim_product) |
| `seller_id` | string | `silver.order_items` (FK → dim_seller) |
| `price` | decimal | `silver.order_items` |
| `freight_value` | decimal | `silver.order_items` |
| `order_purchase_timestamp` | timestamp | `silver.orders` |
| `order_status` | string | `silver.orders` |

## Dimensões
```
                          ┌───────────────┐
                          │ dim_customer  │
                          │ (customer_id) │
                          └───────┬───────┘
                                  │
┌───────────────┐        ┌───────┴────────┐        ┌───────────────┐
│  dim_product  │────────│  fact_orders   │────────│   dim_seller  │
│ (product_id)  │        │                │        │ (seller_id)   │
└───────────────┘        │ order_id       │        └───────────────┘
                         │ order_item_id  │
                         │ customer_id    │
                         │ product_id     │
                         │ seller_id      │
                         │ price          │
                         │ freight_value  │
                         │ purchase_ts    │
                         │ order_status   │
                         └────────────────┘

```
- `fact_orders `no centro (a tabela fato) -cada linha é um item de pedido, com os números que você vai somar/contar (price, freight_value)

- `dim_customer`, `dim_product`, `dim_seller` ao redor (as dimensões) - cada uma descreve "quem"/"o quê" está envolvido naquele fato, e você usa elas pra filtrar e agrupar (ex: "vendas por estado do cliente", "vendas por categoria de produto")

- As linhas conectando (─────) representam o relacionamento: cada `customer_id` dentro de `fact_orders` aponta pra um registro em dim_cu`s`tomer, e assim por diante, é literalmente o desenho de uma estrela (daí o nome "star schema"): um centro, com pontas ao redor.


### `dim_customer`

| Coluna | Origem |
|---|---|
| `customer_id` (PK) | `silver.customers` |
| `customer_city` | `silver.customers` |
| `customer_state` | `silver.customers` |

### `dim_product`
| Coluna | Origem |
|---|---|
| `product_id` (PK) | `silver.products` |
| `product_category_name_english` | join com `product_category_name_translation` |

### `dim_seller`
| Coluna | Origem |
|---|---|
| `seller_id` (PK) | `silver.sellers` |
| `seller_city` | `silver.sellers` |
| `seller_state` | `silver.sellers` |

## Relacionamentos

| De | Para | Cardinalidade |
|---|---|---|
| `fact_orders.customer_id` | `dim_customer.customer_id` | N:1 |
| `fact_orders.product_id` | `dim_product.product_id` | N:1 |
| `fact_orders.seller_id` | `dim_seller.seller_id` | N:1 |



### Decisão de design:
Nessa estapa nós podems:
1. Incluir uma dim_date (dimensão de tempo, comum em star schemas pra facilitar agregações por mês/trimestre/ano)
2. Manter simples só com as 3 dimensões que já mapeamos direto das tabelas Silver.

É uma decisão de design que vale bater o martelo antes de escrever o `notebook 03_gold_aggregation.py.`

Nossa decisão: Vamos incluir uma dim_date (dimensão de tempo),pois é bem comum em star schemas reais, porque facilita muito consultas tipo "vendas por trimestre"
sem precisar extrair mês/ano toda hora na query.

Vamos atualizar o DIAGRAMA.

# Diagrama Atualizado

--- 

Como a dimensão de tempo se conecta pela data (não por um ID como as outras), ela puxa de `order_purchase_timestamp`.

## Diagrama


```
                          ┌───────────────┐
                          │ dim_customer  │
                          │ (customer_id) │
                          └───────┬───────┘
                                  │
┌───────────────┐        ┌───────┴────────┐        ┌───────────────┐
│  dim_product  │────────│  fact_orders   │────────│   dim_seller  │
│ (product_id)  │        │                │        │ (seller_id)   │
└───────────────┘        │ order_id       │        └───────────────┘
                          │ order_item_id  │
                          │ customer_id    │
                          │ product_id     │
                          │ seller_id      │
                          │ price          │
                          │ freight_value  │
                          │ purchase_ts    │
                          │ order_status   │
                          └───────┬────────┘
                                  │
                          ┌───────┴───────┐
                          │   dim_date    │
                          │  (date_key)   │
                          └───────────────┘

```
Imagem aqui
<img width="2720" height="2160" alt="Image" src="https://github.com/user-attachments/assets/1ba9141e-0728-4c4e-beda-b962597e3b62" />

## Tabela Fato: `fact_orders`

Granularidade: **um item de pedido por linha** (mesma granularidade de `silver.order_items`).

| Coluna | Tipo | Origem |
|---|---|---|
| `order_id` | string | `silver.orders` |
| `order_item_id` | int | `silver.order_items` |
| `customer_id` | string | `silver.orders` (FK → dim_customer) |
| `product_id` | string | `silver.order_items` (FK → dim_product) |
| `seller_id` | string | `silver.order_items` (FK → dim_seller) |
| `date_key` | int | derivado de `order_purchase_timestamp` (FK → dim_date) |
| `price` | decimal | `silver.order_items` |
| `freight_value` | decimal | `silver.order_items` |
| `order_purchase_timestamp` | timestamp | `silver.orders` |
| `order_status` | string | `silver.orders` |

## Dimensões

### `dim_customer`
| Coluna | Origem |
|---|---|
| `customer_id` (PK) | `silver.customers` |
| `customer_city` | `silver.customers` |
| `customer_state` | `silver.customers` |

### `dim_product`
| Coluna | Origem |
|---|---|
| `product_id` (PK) | `silver.products` |
| `product_category_name_english` | join com `product_category_name_translation` |

### `dim_seller`
| Coluna | Origem |
|---|---|
| `seller_id` (PK) | `silver.sellers` |
| `seller_city` | `silver.sellers` |
| `seller_state` | `silver.sellers` |

### `dim_date`

Gerada a partir dos valores distintos de `order_purchase_timestamp` em `fact_orders` — não vem de nenhuma tabela Silver diretamente.

| Coluna | Descrição |
|---|---|
| `date_key` (PK) | Data no formato `YYYYMMDD` (int), ex: `20170815` |
| `full_date` | Data completa (`date`) |
| `year` | Ano (ex: 2017) |
| `month` | Mês (1–12) |
| `month_name` | Nome do mês (ex: "Agosto") |
| `quarter` | Trimestre (1–4) |
| `day_of_week` | Dia da semana (1–7) |
| `day_name` | Nome do dia (ex: "Terça-feira") |

## Relacionamentos

| De | Para | Cardinalidade |
|---|---|---|
| `fact_orders.customer_id` | `dim_customer.customer_id` | N:1 |
| `fact_orders.product_id` | `dim_product.product_id` | N:1 |
| `fact_orders.seller_id` | `dim_seller.seller_id` | N:1 |
| `fact_orders.date_key` | `dim_date.date_key` | N:1 |



**Por que dim_date é diferente das outras**

Repare que ela não vem de uma tabela Silver existente (não tem silver.dates),
ela é gerada matematicamente, a partir das datas distintas que aparecem em `fact_orders`. É um padrão clássico de data warehouse: você "explode" um timestamp em várias colunas úteis pra análise (ano, mês, trimestre, dia da semana), pra não precisar calcular isso toda vez numa query.

A chave `date_key` no formato YYYYMMDD (em vez de usar a data como texto) é convenção comum, facilita ordenação e joins performáticos.

Isso vai exigir uma célula extra no `03_gold_aggregation.py` só pra gerar `dim_date`.
