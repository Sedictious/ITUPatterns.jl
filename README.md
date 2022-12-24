This is a collection of short scripts implementing the ITU patterns listed in [here](https://www.itu.int/en/ITU-R/software/Pages/ant-pattern.aspx). This is meant to hopefully help a bit anyone going through the ITU authorization process and looking into re-using one of the already registered radiation patterns.

## Usage

The exact interfaces used depend on the pattern. But generally you just want to initialize the object and then plot the result. A `plot` recipe for antenna patterns is provided so that you can plot your patterns. 

Example usage:

```julia
pattern = APERR_001V01(22.0)
plot(pattern, -π/2, π/2, COPOLAR::AntennaPatternPolarization, color=7)
```

![example](/media/antenna_pattern_test.png)

## Implemented Patterns

### Earth Station Antenna Patterns

#### Standard

- [x] APERR_001V01
- [x] APERR_002V01
- [x] APEREC005V01
- [x] APERR_006V01
- [x] APERR_007V01
- [x] APERR_008V01
- [x] APERR_009V01
- [x] APERR_010V01
- [x] APERR_011V01
- [x] APERR_012V01
- [x] APEREC013V01
- [x] APEREC015V01
- [x] APEREC022V01
- [ ] APEREC023V01
- [ ] APEREC024V01
- [x] APEREC025V01
- [x] APEREC026V01
- [x] APEREC028V01
- [x] APEREC029V01
- [x] APEND_099V01


### Space Station Antenna Patterns

#### Standard

- [ ] APSRR_402V01
- [ ] APSREC407V01
- [ ] APSREC408V01
- [ ] APSREC409V01
- [x] APSREC412V01
- [ ] APSREC413V01
- [ ] APSND_499V01
- [ ] REC-1528

