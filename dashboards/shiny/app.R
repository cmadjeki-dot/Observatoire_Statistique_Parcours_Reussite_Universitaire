library(shiny)
source("helpers.R", local = TRUE, encoding = "UTF-8")
source("methods.R", local = TRUE, encoding = "UTF-8")
project_root <- find_observatory_root()
dashboard_data <- load_dashboard_data(project_root)
years <- sort(unique(dashboard_data$school$annee), decreasing = TRUE)
formations <- c("Toutes les formations" = "all", stats::setNames(
  dashboard_data$formations$formation_id, dashboard_data$formations$libelle_fictif))

kpi_card <- function(label, value, caption, icon = "↗", unavailable = FALSE) {
  tags$article(class = "kpi", tags$div(class = "kpi-label", label,
    tags$span(class = "kpi-icon", `aria-hidden` = "true", icon)),
    tags$div(class = paste("kpi-value", if (unavailable) "unavailable" else ""), value),
    tags$p(class = "kpi-caption", caption))
}

ui <- bootstrapPage(
  tags$head(tags$title("Observatoire étudiant · Shiny"),
    tags$meta(name = "viewport", content = "width=device-width, initial-scale=1"),
    tags$link(rel = "stylesheet", type = "text/css", href = "style.css"),
    tags$link(rel = "stylesheet", type = "text/css", href = "shiny.css")),
  tags$aside(class = "sidebar", tags$a(class = "brand", href = "#",
    tags$span(class = "brand-icon", "O", tags$span("·")),
    tags$span("Observatoire", tags$span(class = "subbrand", "PARCOURS UNIVERSITAIRES"))),
    tags$div(class = "side-label", "ESPACE DE PILOTAGE"),
    radioButtons("view", NULL, c("◫  Vue d’ensemble" = "overview",
      "↗  Parcours & devenir" = "journeys", "≡  Indicateurs & méthode" = "methods"), selected = "overview"),
    tags$div(class = "side-note", tags$span(class = "dot"), "Un laboratoire de données",
      tags$p("Comprendre les chiffres.", tags$br(), "Documenter leurs limites."),
      tags$div(class = "fictive", "100 % FICTIF · R SHINY"))),
  tags$main(
    tags$header(class = "topbar", tags$span("Études & pilotage", tags$span(class = "slash", "/"), "Observatoire étudiant"),
      tags$span(class = "demo-tag", "DÉMONSTRATION · SHINY")),
    tags$section(class = "page-heading", tags$div(tags$div(class = "eyebrow", "RÉUSSITE · PARCOURS · ÉVALUATION"),
      tags$h1("Les parcours en perspective", tags$span(".")),
      tags$p("Des indicateurs pour comprendre les formations et éclairer le pilotage.")),
      tags$div(class = "date-note", "Clôture d’observation", tags$strong("30 septembre 2026"))),
    tags$div(class = "notice", tags$span(class = "info-icon", "i"),
      tags$p(tags$strong("Données entièrement fictives. "),
        "Cette simulation n’est pas affiliée à l’UPEC et ne représente aucun de ses résultats."),
      tags$span(class = "sim-pill", "Simulation")),
    tags$section(class = "filterbar", `aria-label` = "Filtres",
      selectInput("year", "Année universitaire", choices = years, selected = years[1], selectize = FALSE),
      tags$div(class = "formation-filter", selectInput("formation", "Formation", choices = formations,
        selected = "all", selectize = FALSE)),
      actionButton("reset", "Réinitialiser ↺"),
      tags$div(class = "filter-status", textOutput("filter_status", inline = TRUE))),
    tags$div(class = "sr-only", role = "status", `aria-live` = "polite", textOutput("scope")),
    conditionalPanel("input.view == 'overview'",
      tags$div(class = "section-line", tags$h2("Les essentiels"), textOutput("scope_overview", inline = TRUE)),
      uiOutput("kpis", class = "kpi-grid"),
      tags$section(class = "chart-panel", tags$div(class = "chart-head",
        tags$div(tags$div(class = "eyebrow", "TROIS ANNÉES D’OBSERVATION"),
          tags$h2(textOutput("chart_title", inline = TRUE)), textOutput("chart_subtitle")),
        radioButtons("metric", NULL, choices = c("Validation" = "success", "Effectifs" = "enrolment",
          "Satisfaction" = "satisfaction"), selected = "success", inline = TRUE)),
        plotOutput("evolution_plot", height = "285px"),
        tags$div(class = "chart-footer", tags$span(tags$i(class = "legend-dot"), textOutput("formation_label", inline = TRUE)),
          tags$span("Source : simulation R · jeu préparé")),
        tags$details(class = "data-details", tags$summary("Voir les valeurs du graphique"), tableOutput("chart_table"))),
      tags$div(class = "bottom-grid", tags$section(class = "small-panel",
        tags$div(class = "eyebrow", "SUIVI DES RÉSULTATS"), tags$h2("Lire un taux avec sa couverture"),
        uiOutput("coverage"), tags$p(class = "muted", "Un résultat inconnu n’est pas un échec individuel.")),
        tags$section(class = "small-panel insight", tags$div(class = "eyebrow", "LE REPÈRE MÉTHODOLOGIQUE"),
          tags$h2("Un chiffre, un périmètre."), tags$p("La satisfaction décrit les avis exprimés. L’emploi dépend de l’année du diplôme et de l’horizon atteint. Aucun taux ne se lit sans son dénominateur."),
          actionButton("open_methods", "Comprendre les 8 indicateurs ↗", class = "text-button")))),
    conditionalPanel("input.view == 'journeys'",
      tags$div(class = "section-line", tags$h2("Parcours & devenir"), tags$span("Cohorte de départ : année sélectionnée")),
      uiOutput("journey_kpis", class = "kpi-grid"),
      tags$section(class = "small-panel", tags$h2("Ce que l’on peut observer"), textOutput("journey_context"),
        tags$p("Une absence de réinscription ne prouve pas un abandon. Les sorties documentées, situations inconnues et fins de cycle diplômées restent distinctes."),
        uiOutput("employment_detail"))),
    conditionalPanel("input.view == 'methods'",
      tags$div(class = "section-line", tags$h2("Les 8 indicateurs à maîtriser"), tags$span("Définitions du démonstrateur")),
      tags$p(class = "method-intro", "Chaque résultat associe une population, une fenêtre d’observation et une règle de calcul. Ouvrez les fiches pour consulter les exclusions et les points de vigilance."),
      lapply(seq_along(dashboard_methods), function(i) {
        m <- dashboard_methods[[i]]
        tags$details(class = "method", tags$summary(sprintf("%02d · %s", i, m[[1]])),
          tags$p(m[[2]]), tags$code(class = "formula", m[[3]]), tags$p(m[[4]]))
      }),
      tags$section(class = "small-panel", tags$h2("Quatre réflexes de lecture"),
        tags$ul(class = "rules", tags$li("Recalculer les taux à partir des comptes, jamais par moyenne simple de pourcentages."),
          tags$li("Distinguer personnes uniques dans une année et inscriptions cumulées sur plusieurs années."),
          tags$li("Distinguer non calculable, non observable et masqué, sans les remplacer par zéro."),
          tags$li("Les écarts viennent d’hypothèses de simulation : aucune conclusion causale ou institutionnelle.")))),
    tags$footer(tags$span("Observatoire étudiant ", tags$strong("·"), " Démonstrateur statistique"),
      tags$span("Données fictives · R / Shiny / renv / targets")))
)

server <- function(input, output, session) {
  snapshot <- reactive({
    req(input$year %in% years, input$formation %in% unname(formations))
    dashboard_snapshot(dashboard_data, input$year, input$formation)
  })
  formation_label <- reactive(names(formations)[match(input$formation, unname(formations))])
  series <- reactive({req(input$metric, input$formation); dashboard_series(dashboard_data, input$formation, input$metric)})
  output$scope <- output$scope_overview <- renderText(paste(input$year, formation_label(), sep = " · "))
  output$formation_label <- renderText(formation_label())
  output$filter_status <- renderText(if (input$formation == "all") "5 formations sélectionnées" else "1 formation sélectionnée")
  observeEvent(input$reset, {
    updateSelectInput(session, "year", selected = years[1])
    updateSelectInput(session, "formation", selected = "all")
  })
  observeEvent(input$open_methods, updateRadioButtons(session, "view", selected = "methods"))
  output$kpis <- renderUI({
    x <- snapshot(); s <- x$school; e <- x$survey; g <- x$employment
    known <- identical(s$state, "ok"); survey_known <- identical(e$state, "ok")
    employment_caption <- if (x$censored) "Diplômés de juillet 2026 : horizon non atteint" else if (g$state == "masked")
      "Petits comptes et compléments protégés" else paste(dashboard_number(g$emploi), "/", dashboard_number(g$situations_connues), "situations connues")
    tagList(
      kpi_card("Étudiants inscrits", if (known) dashboard_number(s$inscrits) else dashboard_status(s),
        if (is.na(x$evolution)) "Évolution : année précédente indisponible" else paste0(
          if (x$evolution >= 0) "+" else "", dashboard_pct(x$evolution), " par rapport à l’année précédente"), "◫", !known),
      kpi_card("Validation annuelle", if (is.na(x$success)) dashboard_status(s) else dashboard_pct(x$success),
        if (known) paste(dashboard_number(s$validations), "validations /", dashboard_number(s$inscrits), "éligibles") else "Données indisponibles", "✓", is.na(x$success)),
      kpi_card("Satisfaction", if (is.na(x$satisfaction)) dashboard_status(e) else dashboard_pct(x$satisfaction),
        if (survey_known) paste(dashboard_number(e$satisfaits), "/", dashboard_number(e$avis), "avis · participation", dashboard_pct(x$participation)) else "Données indisponibles", "☆", is.na(x$satisfaction)),
      kpi_card("Emploi à six mois", if (x$censored) "Non observable" else if (is.na(x$employment_rate)) dashboard_status(g) else dashboard_pct(x$employment_rate),
        employment_caption, "↗", x$censored || is.na(x$employment_rate)))
  })
  output$coverage <- renderUI({
    x <- snapshot(); s <- x$school
    tagList(tags$div(class = "coverage-row", tags$strong(dashboard_pct(x$coverage)), tags$span("des résultats sont connus")),
      tags$div(class = "progress", tags$span(style = paste0("width:", if (is.na(x$coverage)) 0 else 100*x$coverage, "%;"))),
      tags$p(if (s$state == "ok") paste(dashboard_number(s$inconnus), "résultats inconnus. Validation parmi les résultats connus :",
        dashboard_pct(dashboard_rate(s, "validations", "connus"))) else "Données indisponibles ou protégées."))
  })
  output$chart_title <- renderText(switch(input$metric, enrolment = "Évolution des effectifs inscrits",
    satisfaction = "Évolution de la satisfaction", "Évolution de la validation annuelle"))
  output$chart_subtitle <- renderText(switch(input$metric, enrolment = "Étudiants distincts dans chaque année universitaire",
    satisfaction = "Notes 4 ou 5 / avis exprimés de 1 à 5", "Validations connues / inscriptions éligibles"))
  output$evolution_plot <- renderPlot({
    chart <- series(); validate(need(any(!is.na(chart$valeur)), "Données indisponibles ou protégées pour ce périmètre."))
    chart$etiquette <- vapply(chart$valeur, if (input$metric == "enrolment") dashboard_number else dashboard_pct, character(1))
    chart$selection <- chart$annee == input$year
    p <- ggplot2::ggplot(chart, ggplot2::aes(annee, valeur, group = 1)) +
      ggplot2::geom_area(fill = "#edf3e7", na.rm = TRUE) + ggplot2::geom_line(colour = "#347e61", linewidth = 1, na.rm = TRUE) +
      ggplot2::geom_point(ggplot2::aes(size = selection), colour = "#347e61", fill = "white", shape = 21, stroke = 1.2, na.rm = TRUE) +
      ggplot2::geom_text(ggplot2::aes(label = etiquette), vjust = -1.3, colour = "#316949", size = 3.5, na.rm = TRUE) +
      ggplot2::scale_size_manual(values = c("FALSE" = 2.8, "TRUE" = 4), guide = "none") +
      ggplot2::labs(x = NULL, y = NULL, alt = paste("Évolution sur trois années,", formation_label(), "données entièrement fictives.")) +
      ggplot2::theme_minimal(base_size = 11) + ggplot2::theme(panel.grid.minor = ggplot2::element_blank(),
        panel.grid.major.x = ggplot2::element_blank(), panel.grid.major.y = ggplot2::element_line(colour = "#edf1e9"),
        axis.text = ggplot2::element_text(colour = "#7d8d7f"), plot.margin = ggplot2::margin(20, 20, 10, 10))
    if (input$metric == "enrolment") p + ggplot2::scale_y_continuous(limits = c(0, max(chart$valeur, na.rm = TRUE)*1.15),
      labels = function(x) vapply(x, dashboard_number, character(1))) else p + ggplot2::scale_y_continuous(limits = c(0, 1),
        labels = function(x) vapply(x, dashboard_pct, character(1)))
  }, res = 110)
  output$chart_table <- renderTable({x <- series(); data.frame(Année = x$annee,
    Valeur = vapply(x$valeur, if (input$metric == "enrolment") dashboard_number else dashboard_pct, character(1)), check.names = FALSE)}, striped = FALSE)
  output$journey_kpis <- renderUI({
    x <- snapshot(); s <- x$school
    specs <- list(c("Passage", "passages", "eligibles_passage"), c("Réorientation", "reorientations", "suivis"),
      c("Sortie documentée", "sorties_observees", "suivis"), c("Situation inconnue", "situations_inconnues", "suivis"))
    tagList(lapply(specs, function(spec) {
      value <- dashboard_rate(s, spec[2], spec[3])
      kpi_card(spec[1], if (x$censored) "Non observable" else if (is.na(value)) dashboard_status(s) else dashboard_pct(value),
        if (x$censored) "L’année suivante est hors de la fenêtre" else if (s$state == "ok") paste(
          dashboard_number(s[[spec[2]]]), "/", dashboard_number(s[[spec[3]]]), "inscriptions de référence") else "Données protégées",
        unavailable = x$censored || is.na(value))
    }))
  })
  output$journey_context <- renderText(if (snapshot()$censored)
    "La cohorte 2025-2026 ne peut pas être suivie en 2026-2027 à cette clôture. Les transitions sont censurées, elles ne valent pas zéro."
    else paste("La cohorte de départ", input$year, "est suivie à l’inscription de l’année suivante. Le passage exclut les niveaux terminaux ; les autres taux utilisent la cohorte suivable complète."))
  output$employment_detail <- renderUI({
    x <- snapshot(); g <- x$employment
    if (x$censored) tags$p(class = "inline-warning", "Devenir des diplômés 2025-2026 : non observable à six mois au 30 septembre 2026.")
    else if (g$state == "masked") tags$p(class = "inline-warning", "Les données d’insertion de cette année sont masquées. Les comptes et leurs compléments sont retirés avant chargement ; un filtre ne peut pas les révéler.")
    else tags$p("Participation insertion : ", dashboard_pct(dashboard_rate(g, "repondants", "sollicites")),
      ". Emploi parmi situations connues : ", dashboard_pct(x$employment_rate),
      ". Insertion parmi actifs : ", dashboard_pct(dashboard_rate(g, "emploi", "actifs")), ".")
  })
}

shinyApp(ui = ui, server = server)
