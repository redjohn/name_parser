parser = require '../nameParser'

describe "Name Parser", ->
    it "should parse the name format 'first middle(s) last[,] suffix(es)'", ->
        name = parser.parse_human_name 'Sterling Mallory Archer, Esq'
        should_equal name, ['', 'Sterling', 'Mallory', 'Archer', 'Esq']

    it "should parse the name format 'last, first middle(s)[,] suffix(es)'", ->
        name = parser.parse_human_name 'Archer, Sterling Mallory, Esq'
        should_equal name, ['', 'Sterling', 'Mallory', 'Archer', 'Esq']

should_equal = (parsed_name, names) ->
    equal parsed_name.title, names[0]
    equal parsed_name.first, names[1]
    equal parsed_name.middle(), names[2]
    equal parsed_name.last(), names[3]
    equal parsed_name.suffix(), names[4]

