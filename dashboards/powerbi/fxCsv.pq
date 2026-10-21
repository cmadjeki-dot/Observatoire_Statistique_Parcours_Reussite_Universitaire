// Creer une requete vide nommee fxCsv et coller cette fonction.
(nom as text, textes as list, optional masque as nullable logical) as table =>
let
    Source = Csv.Document(File.Contents(DossierExports & nom),
        [Delimiter=",", Encoding=65001, QuoteStyle=QuoteStyle.Csv]),
    Entetes = Table.PromoteHeaders(Source, [PromoteAllScalars=true]),
    Vides = Table.ReplaceValue(Entetes, "", null, Replacer.ReplaceValue, Table.ColumnNames(Entetes)),
    Numeriques = List.Difference(Table.ColumnNames(Vides), textes),
    TypesNumeriques = List.Transform(Numeriques, each {_, Int64.Type}),
    TypesTexte = List.Transform(List.RemoveItems(textes, {"masque"}), each {_, type text}),
    Types = Table.TransformColumnTypes(Vides, TypesNumeriques & TypesTexte, "en-US"),
    Resultat = if masque = true then
        Table.TransformColumns(Types, {{"masque", each if _ = null then error "Masque absent"
            else if Text.Upper(_) = "TRUE" then true
            else if Text.Upper(_) = "FALSE" then false
            else error "Masque invalide", type logical}})
        else Types
in
    Resultat
