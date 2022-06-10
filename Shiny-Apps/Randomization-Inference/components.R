wrapper <- function(...) {
	div(
		class = "w-full xl:max-w-[58rem] mx-auto min-h-screen mb-48 py-12 px-4",
		...
	)
}

border_container <- function(class = "", ...) {
	if(is.character(class)) {
		div(
			class = paste("w-full p-4 bg-white rounded-lg border-2", class),
			...
		)
	} else {
		div(
			class = paste("w-full p-4 bg-white rounded-lg border-2"),
			class, ...
		)
	}
}


gradient_header <- function(text = "", from = "#67b26f", to = "#4ca2cd") {
	h1(
		class = "border-b-2 border-slate-200",
		span(class = glue::glue("inline-block text-4xl font-black bg-gradient-to-r text-transparent bg-clip-text from-[{from}] to-[{to}]"), text)
	)
}
caps_header <- function(text = "", class="", ...) {
	h3(class = paste("text-[#00b7ff] uppercase text-sm font-semibold mb-4", class), text)
}




