###
A simple script for parsing human names into their individual components.

Components::

    * Title
    * First name
    * Middle names
    * Last names
    * Suffixes

Works for a variety of common name formats for latin-based languages. Over
100 unit tests with example names. Should be unicode safe but it's fairly untested.

HumanName instances will pass an equals (==) test if their string representations are the same.

--------

Copyright Derek Gulbranson, May 2009 <derek73 at gmail>.
http://code.google.com/p/python-nameparser

Parser logic based on PHP nameParser.php by G. Miernicki
http://code.google.com/p/nameparser/

LGPL
http://www.opensource.org/licenses/lgpl-license.html

This library is free software; you can redistribute it and/or modify it under the terms of the GNU Lesser
General Public License as published by the Free Software Foundation; either version 2.1 of the License, or (at
your option) any later version.

This library is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the
implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public
License for more details.
###

TITLES = ['dr','doctor','miss','misses','mr','mister','mrs','ms','judge','sir','rev','madam','madame','AB','2ndLt','Amn','1stLt','A1C','Capt','SrA','Maj','SSgt','LtCol','TSgt','Col','BrigGen','1stSgt','MajGen','SMSgt','LtGen','1stSgt','Gen','CMSgt','1stSgt','CCMSgt','CMSAF','PVT','2LT','PV2','1LT','PFC','CPT','SPC','MAJ','CPL','LTC','SGT','COL','SSG','BG','SFC','MG','MSG','LTG','1SGT','GEN','SGM','CSM','SMA','WO1','WO2','WO3','WO4','WO5','ENS','SA','LTJG','SN','LT','PO3','LCDR','PO2','CDR','PO1','CAPT','CPO','RADM(LH)','SCPO','RADM(UH)','MCPO','VADM','MCPOC','ADM','MPCO-CG','CWO-2','CWO-3','CWO-4','Pvt','2ndLt','PFC','1stLt','LCpl','Capt','Cpl','Maj','Sgt','LtCol','SSgt','Col','GySgt','BGen','MSgt','MajGen','1stSgt','LtGen','MGySgt','Gen','SgtMaj','SgtMajMC','WO-1','CWO-2','CWO-3','CWO-4','CWO-5','ens','sa','ltjg','sn','lt','po3','lcdr','po2','cdr','po1','capt','cpo','rdml','scpo','radm','mcpo','vadm','mcpon','adm','fadm','wo1','cwo2','cwo3','cwo4','cwo5']
# These could be names too, but if they have period at the end they're a title
PUNC_TITLES = ['hon.','sr.']
PREFICES = ['abu','bon','ben','bin','da','dal','de','del','der','de','e','ibn','la','san','st','ste','van','vel','von','Captain','Dr','Father','Miss','Mr','Mrs','Ms','Officer','Prof','Sister','Sr']
SUFFICES = ['esq','esquire','jr','sr','2','ii','iii','iv','clu','chfc','cfp','md','phd', 'anp','apn','apnp','aprn','arnp','at','atc','at-c','cht','cnm','cnp','cns','cpnp','crna','crnp','cws','dc','dds','dmd','do','dplc','dpm','dpt','dvm','edd','facp','fnp','jd','lac','lcsw','licsw','lmft','lmhc','lmp','lmsw','lmt','lpc','lpn','ma','md','md phd','mds','mdx','mft','mph','mpt','ms','msn','mspt','msw','mx','mxrt','nd','nnp','np','np-c','od','ot','otr','pa','pac','pa-c','pc','pharm d','pharmd','phd','pnp','psc','psyd','pt','pta','rd','rda','rn','rnc','rpa-c','rph','slp','vmd', '2nd','3rd','ii','iii','iv','ix','jr','sr','vi','vii','viii','x','dds','dmd','rdh','rad','ld','professor','deputy','dphil','bs','ass']
CAPITALIZATION_EXCEPTIONS = {
    'ii': 'II',
    'iii': 'III',
    'iv': 'IV',
    'md': 'M.D.',
    'phd': 'Ph.D.'
}
CONJUNCTIONS = ['&', 'and', 'et', 'e', 'und', 'y']

re_spaces = /\s+/g
re_word = /\w+/
re_mac = /^(ma?c)(\w)/i
re_initial = /^(\w\.|[A_Z])?$/

lc = (value) ->
    return "" if not value
    return value.toLowerCase().replace('.','')

is_not_initial = (value) ->
    return not value.match(re_initial)

class HumanName
    constructor: (@full_name='', @titles=TITLES, @prefices=PREFICES, @suffices=SUFFICES, @punc_titles=PUNC_TITLES, @conjunctions=CONJUNCTIONS, @capitalization_exceptions=CAPITALIZATION_EXCEPTIONS) ->
        this.titles = @titles
        this.punc_titles = @punc_titles
        this.conjunctions = @conjunctions
        this.prefices = @prefices
        this.suffices = @suffices
        this.capitalization_exceptions = @capitalization_exceptions
        this.full_name = @full_name
        this.title = ""
        this.first = ""
        this.suffixes = []
        this.middle_names = []
        this.last_names = []
        this.unparsable = false
        this.count = 0
        this.members = ['title','first','middle','last','suffix']
        if this.full_name
            this.parse_full_name()

    middle: -> this.middle_names.join(' ')

    last: -> this.last_names.join(' ')

    suffix: -> this.suffixes.join(', ')

    is_conjunction: (@piece) -> lc(@piece) in this.conjunctions and is_not_initial(@piece)

    is_prefix: (@piece) -> lc(@piece) in this.prefices and is_not_initial(@piece)

    parse_full_name: ->
        if not this.full_name
            throw "Missing full_name"

        #if not isinstance(self.full_name, unicode):
        #    self.full_name = unicode(self.full_name, ENCODING)

        # collapse multiple spaces
        this.full_name = this.full_name.trim().replace(re_spaces, ' ')

        # reset values
        this.title = ""
        this.first = ""
        this.suffixes = []
        this.middle_names = []
        this.last_names = []
        this.unparsable = false

        # break up full_name by commas
        parts = (x.trim() for x in this.full_name.split(","))

        #log.debug(u"full_name: " + self.full_name)
        #log.debug(u"parts: " + unicode(parts))

        pieces = []
        if parts.length == 1

            # 'no commas, title first middle middle middle last suffix'

            for part in parts
                part = String(part)
                names = part.split(' ')
                for name in names
                    name = name.replace(',','').trim()
                    pieces.push(name)

            #log.debug(u"pieces: " + unicode(pieces))

            i = 0
            while i < pieces.length
                piece = pieces[i]
                try
                    next = pieces[i + 1]
                catch error
                    next = null

                try
                    prev = pieces[i - 1]
                catch error
                    prev = null

                if lc(piece) in this.titles
                    this.title = piece
                    i += 1
                    continue
                if piece.toLowerCase() in this.punc_titles
                    this.title = piece
                    i += 1
                    continue
                if not this.first
                    this.first = piece.replace(".","")
                    i += 1
                    continue
                if (i == pieces.length - 2) and (lc(next) in this.suffices)
                    this.last_names.push(piece)
                    this.suffixes.push(next)
                    break
                if this.is_prefix(piece)
                    this.last_names.push(piece)
                    i += 1
                    continue
                if this.is_conjunction(piece) and i < pieces.length / 2
                    this.first += ' ' + piece
                    i += 1
                    continue
                if this.is_conjunction(prev) and (i-1) < pieces.length / 2
                    this.first += ' ' + piece
                    i += 1
                    continue
                if this.is_conjunction(piece) or this.is_conjunction(next)
                    this.last_names.push(piece)
                    i += 1
                    continue
                if i == pieces.length - 1
                    this.last_names.push(piece)
                    i += 1
                    continue
                this.middle_names.push(piece)
                i += 1
                ###
                   Got to here
                ###
        else
            if lc(parts[1]) in this.suffices

                # 'title first middle last, suffix [, suffix]'

                names = parts[0].split(' ')
                for name in names
                    name = name.replace(',','').trim()
                    pieces.push(name)

                #log.debug(u"pieces: " + unicode(pieces))

                this.suffixes.push part for part in parts[1..parts.length]

                while i < pieces.length
                    piece = pieces[i]
                    try
                        next = pieces[i + 1]
                    catch error
                        next = null

                    if lc(piece) in this.titles
                        this.title = piece
                        i += 1
                        continue
                    if piece.toLowerCase() in this.punc_titles
                        this.title = piece
                        i += 1
                        continue
                    if not this.first
                        this.first = piece.replace(".","")
                        i += 1
                        continue
                    if i == (pieces.length -1) and this.is_prefix(piece) and next
                        this.last_names.push(piece + " " + next)
                        break
                    if this.is_prefix(piece)
                        this.last_names.push(piece)
                        i += 1
                        continue
                    if this.is_conjunction(piece) or this.is_conjunction(next)
                        this.last_names.push(piece)
                        i += 1
                        continue
                    if i == pieces.length - 1
                        this.last_names.push(piece)
                        i += 1
                        continue
                    this.middle_names.push(piece)
                    i += 1
            else

                # 'last, title first middles[,] suffix [,suffix]'

                names = parts[1].split(' ')
                for name in names
                    name = name.replace(',','').trim()
                    pieces.push(name)

                #log.debug(u"pieces: " + unicode(pieces))

                this.last_names.push parts[0]
                i = 0
                while i < pieces.length
                    piece = pieces[i]
                    try
                        next = pieces[i + 1]
                    catch error
                        next = null

                    if lc(piece) in this.titles
                        this.title = piece
                        i += 1
                        continue
                    if piece.toLowerCase() in this.punc_titles
                        this.title = piece
                        i += 1
                        continue
                    if not this.first
                        this.first = piece.replace(".","")
                        i += 1
                        continue
                    if lc(piece) in this.suffices
                        this.suffixes.push(piece)
                        i += 1
                        continue
                    this.middle_names.push(piece)
                    i += 1
                try
                    if parts[2]
                        this.suffixes.push part for part in parts[2..parts.length]
                catch error
                    null

        if not this.first and this.middle_names.length < 1 and this.last_names.length < 1
            this.unparsable = true
            #log.error(u"Unparsable full_name: " + this.full_name)

exports.parse_human_name = (name) ->
    new HumanName name
