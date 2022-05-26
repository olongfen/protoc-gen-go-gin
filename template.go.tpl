type {{ $.InterfaceName }} interface {
{{range .MethodSet}}
	{{.Name}}(context.Context, *{{.Request}}) (*{{.Reply}}, error)
{{end}}
}



func Register{{ $.InterfaceName }}(r gin.IRouter, srv {{ $.InterfaceName }}) {
	s := {{.Name}}{
		server: srv,
		router:     r,
	}
	s.RegisterService()
}

type {{$.Name}} struct{
	server {{ $.InterfaceName }}
	router gin.IRouter
}


{{range .Methods}}
func (s *{{$.Name}}) {{ .HandlerName }} (ctx *gin.Context) {
	var in {{.Request}}
{{if .HasPathParams }}
	if err := ctx.ShouldBindUri(&in); err != nil {
		response.Error(ctx, err.Error())
		return
	}
{{end}}
{{if eq .Method "GET" }}
	if err := ctx.ShouldBindQuery(&in); err != nil {
		response.Error(ctx, err.Error())
		return
	}
{{else if eq .Method "DELETE"}}
    if err := ctx.ShouldBindQuery(&in); err != nil {
    		if err=ctx.ShouldBind(&in);err!=nil{
    		    response.Error(ctx, err.Error())
    		    return
    		}
    }
{{else if eq .Method "POST" "PUT" }}
	if err := ctx.ShouldBindJSON(&in); err != nil {
		response.Error(ctx, err.Error())
		return
	}
{{else}}
	if err := ctx.ShouldBind(&in); err != nil {
		response.Error(ctx, err.Error())
		return
	}
{{end}}
	md := metadata.New(nil)
	for k, v := range ctx.Request.Header {
		md.Set(k, v...)
	}
	newCtx := metadata.NewIncomingContext(ctx, md)
	out, err := s.server.({{ $.InterfaceName }}).{{.Name}}(newCtx, &in)
	if err != nil {
		response.Error(ctx, err.Error())
		return
	}

	response.Success(ctx, out)
}
{{end}}

func (s *{{$.Name}}) RegisterService() {
{{range .Methods}}
		s.router.Handle("{{.Method}}", "{{.Path}}", s.{{ .HandlerName }})
{{end}}
}