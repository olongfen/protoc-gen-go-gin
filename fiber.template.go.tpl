type {{ $.InterfaceFiberName }} interface {
{{range .MethodSet}}
	{{.Name}}(context.Context, *{{.Request}}) (*{{.Reply}}, error)
{{end}}
}



func Register{{ $.InterfaceFiberName }}(r v2.Router, srv {{ $.InterfaceFiberName }}) {
	s := {{.Name}}Fiber{
		server: srv,
		router:     r,
	}
	s.RegisterService()
}

type {{$.Name}}Fiber struct{
	server {{ $.InterfaceFiberName }}
	router v2.Router
}


{{range .Methods}}
func (s *{{$.Name}}Fiber) {{ .HandlerName }} (ctx *v2.Ctx)error {
	var in {{.Request}}
{{if .HasPathParams }}
	if err := ctx.ParamsParser(&in); err != nil {
		return response.FiberRespFailFunc(ctx,err.Error())
	}
{{end}}
{{if eq .Method "GET" }}
	if err := ctx.QueryParser(&in); err != nil {
		return response.FiberRespFailFunc(ctx,err.Error())
	}
{{else if eq .Method "DELETE"}}
          if err := ctx.ParamsParser(&in); err != nil {
               return response.FiberRespFailFunc(ctx,err.Error())
          }
        if err=ctx.QueryParser(&in);err!=nil{
            return response.FiberRespFailFunc(ctx,err.Error())
        }
{{else}}
	if err := ctx.BodyParser(&in); err != nil {
		  return response.FiberRespFailFunc(ctx,err.Error())
	}
{{end}}
	md := metadata.New(nil)
    for k, v := range ctx.GetReqHeaders() {
    		md.Set(k, v)
    }
    newCtx := metadata.NewIncomingContext(ctx.Context(), md)
	out, err := s.server.({{ $.InterfaceFiberName }}).{{.Name}}(newCtx, &in)
	if err != nil {
		return  response.FiberRespFailFunc(ctx,err.Error())
	}

	return response.FiberRespSuccessFunc(ctx, out)
}
{{end}}

func (s *{{$.Name}}Fiber) RegisterService() {
{{range .Methods}}
		s.router.Add("{{.Method}}", "{{.Path}}", s.{{ .HandlerName }})
{{end}}
}