parser = require '../name_parser'

describe "Name Parser", ->
    describe "given the format 'title first middle(s) last suffix'", ->
        it "should parse correctly with a title", ->
            name = parser.parse_human_name 'Mr. Sterling Mallory Archer'
            should_equal name, ['Mr.', 'Sterling', 'Mallory', 'Archer', '']

        it "should parse correctly with a suffix", ->
            name = parser.parse_human_name 'Sterling Mallory Archer Esq'
            should_equal name, ['', 'Sterling', 'Mallory', 'Archer', 'Esq']

        it "should parse correctly with multiple middle names", ->
            name = parser.parse_human_name 'Sterling Mallory Cyril Archer'
            should_equal name, ['', 'Sterling', 'Mallory Cyril', 'Archer', '']

        it "should parse correctly with no middle names", ->
            name = parser.parse_human_name 'Sterling Archer'
            should_equal name, ['', 'Sterling', '', 'Archer', '']

    describe "given the format 'title first middle(s) last, suffix [, suffix] ...'", ->
        it "should parse correctly with a title", ->
            name = parser.parse_human_name 'Mr. Sterling Mallory Archer'
            should_equal name, ['Mr.', 'Sterling', 'Mallory', 'Archer', '']

        it "should parse correctly with multiple middle names", ->
            name = parser.parse_human_name 'Sterling Mallory Cyril Archer'
            should_equal name, ['', 'Sterling', 'Mallory Cyril', 'Archer', '']

        it "should parse correctly with no middle names", ->
            name = parser.parse_human_name 'Sterling Archer'
            should_equal name, ['', 'Sterling', '', 'Archer', '']

        it "should parse correctly with one suffix", ->
            name = parser.parse_human_name 'Sterling Mallory Archer, Esq'
            should_equal name, ['', 'Sterling', 'Mallory', 'Archer', 'Esq']

        it "should parse correctly with multiple suffixes", ->
            name = parser.parse_human_name 'Sterling Mallory Archer, Esq, Esquire'
            should_equal name, ['', 'Sterling', 'Mallory', 'Archer', 'Esq, Esquire']

    describe "given the format 'last, title first middle(s)[,] suffix(es)'", ->
        it "should parse correctly with a title", ->
            name = parser.parse_human_name 'Archer, Mr. Sterling Mallory, Esq'
            should_equal name, ['Mr.', 'Sterling', 'Mallory', 'Archer', 'Esq']

        it "should parse correctly with no suffix", ->
            name = parser.parse_human_name 'Archer, Sterling Mallory'
            should_equal name, ['', 'Sterling', 'Mallory', 'Archer', '']

        it "should parse correctly with multiple middle names", ->
            name = parser.parse_human_name 'Archer, Sterling Mallory Cyril, Esq'
            should_equal name, ['', 'Sterling', 'Mallory Cyril', 'Archer', 'Esq']

        it "should parse correctly with no middle names", ->
            name = parser.parse_human_name 'Archer, Sterling, Esq'
            should_equal name, ['', 'Sterling', '', 'Archer', 'Esq']

        describe "with one suffix", ->
            it "should parse correctly with a comma", ->
                name = parser.parse_human_name 'Archer, Sterling Mallory, Esq'
                should_equal name, ['', 'Sterling', 'Mallory', 'Archer', 'Esq']

            it "should parse correctly with no comma", ->
                name = parser.parse_human_name 'Archer, Sterling Mallory Esq'
                should_equal name, ['', 'Sterling', 'Mallory', 'Archer', 'Esq']

        describe "with multiple suffixes", ->
            it "should parse correctly with no comma", ->
                name = parser.parse_human_name 'Archer, Sterling Mallory Esq Esquire'
                should_equal name, ['', 'Sterling', 'Mallory', 'Archer', 'Esq, Esquire']

            it "should parse correctly with a comma", ->
                name = parser.parse_human_name 'Archer, Sterling Mallory, Esq Esquire'
                should_equal name, ['', 'Sterling', 'Mallory', 'Archer', 'Esq, Esquire']

            it "should parse correctly with multiple commas", ->
                name = parser.parse_human_name 'Archer, Sterling Mallory, Esq, Esquire'
                should_equal name, ['', 'Sterling', 'Mallory', 'Archer', 'Esq, Esquire']

    it "should ignore extra whitespace", ->
        name = parser.parse_human_name ' Sterling  Mallory   Archer '
        should_equal name, ['', 'Sterling', 'Mallory', 'Archer', '']

should_equal = (parsed_name, names) ->
    equal parsed_name.title, names[0]
    equal parsed_name.first, names[1]
    equal parsed_name.middle(), names[2]
    equal parsed_name.last(), names[3]
    equal parsed_name.suffix(), names[4]

