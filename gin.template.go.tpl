type {{ $.InterfaceGinName }} interface {
{{range .MethodSet}}
	{{.Name}}(context.Context, *{{.Request}}) (*{{.Reply}}, error)
{{end}}
}



func Register{{ $.InterfaceGinName }}(r gin.IRouter, srv {{ $.InterfaceGinName }}) {
	s := {{.Name}}Gin{
		server: srv,
		router:     r,
	}
	s.RegisterService()
}

type {{$.Name}}Gin struct{
	server {{ $.InterfaceGinName }}
	router gin.IRouter
}


{{range .Methods}}
func (s *{{$.Name}}Gin) {{ .HandlerName }} (ctx *gin.Context) {
	var in {{.Request}}
{{if .HasPathParams }}
	if err := ctx.ShouldBindUri(&in); err != nil {
		response.GinError(ctx, err.Error())
		return
	}
{{end}}
{{if eq .Method "GET" }}
	if err := ctx.ShouldBindQuery(&in); err != nil {
		response.GinError(ctx, err.Error())
		return
	}
{{else if eq .Method "DELETE"}}
    if err := ctx.ShouldBindQuery(&in); err != nil {
    		if err=ctx.ShouldBind(&in);err!=nil{
    		    response.GinError(ctx, err.Error())
    		    return
    		}
    }
{{else if eq .Method "POST" "PUT" }}
	if err := ctx.ShouldBindJSON(&in); err != nil {
		response.GinError(ctx, err.Error())
		return
	}
{{else}}
	if err := ctx.ShouldBind(&in); err != nil {
		response.GinError(ctx, err.Error())
		return
	}
{{end}}
	md := metadata.New(nil)
	for k, v := range ctx.Request.Header {
		md.Set(k, v...)
	}
	newCtx := metadata.NewIncomingContext(ctx.Request.Context(), md)
	out, err := s.server.({{ $.InterfaceGinName }}).{{.Name}}(newCtx, &in)
	if err != nil {
		response.GinError(ctx, err.Error())
		return
	}

	response.GinSuccess(ctx, out)
}
{{end}}

func (s *{{$.Name}}Gin) RegisterService() {
{{range .Methods}}
		s.router.Handle("{{.Method}}", "{{.Path}}", s.{{ .HandlerName }})
{{end}}
}