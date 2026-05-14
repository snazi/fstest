# Presentation Layer Patterns

## Predictor/Feature Definitions

Define the predictor variables used in the presentation layer's scoring or classification logic. Customize for the project's specific domain.

### Template

```
## Phase/Stage <N> (<data source> predictors)

Predictors:
- <PREDICTOR_1>
- <PREDICTOR_2>
- <PREDICTOR_N>

Coding notes:
- Binary predictors encoded as 1 = matching condition, 0 = otherwise.
- Ordinal predictors use defined ordinal coding.
- All predictor additions are encoded as 1 = Yes, 0 = No/other.
```

## Output Contract

Define the presentation layer output contract. Customize for the project's specific domain.

### Template

```
Grain:
- Exactly one row per (<primary key>, <secondary key>).
- Built from mart only.

Required mart dependencies:
- mart.<entity_1> (filter <condition>)
- mart.<entity_2>
- mart.<entity_3> (aggregated)

Required identity columns:
- <primary_key>
- <secondary_key>

Core output fields:
- <field_1>
- <field_2>
- <status_field>

Status derivation rules:
- <status_field> derived from <scoring/threshold logic>

Operational/context fields:
- <context_field_1>
- <context_field_2>
- _last_updated_ts
```

## Common Patterns

- **All presentation features must be sourced from mart tables only** — no direct Bronze/Silver dependencies.
- **Feature engineering** (binary encoding, ordinal coding, aggregations) belongs in this layer.
- **Business scoring and status classification** belongs in this layer.
- **Threshold handling** should be configurable, not hardcoded.
- **Output grain** must be explicitly defined and validated.
