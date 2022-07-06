type {{ $.InterfaceName }} interface {
{{range .MethodSet}}
	{{.Name}}(context.Context, *{{.Request}}) (*{{.Reply}}, error)
{{end}}
}



func Register{{ $.InterfaceName }}(r fiber.Router, srv {{ $.InterfaceName }}) {
	s := {{.Name}}{
		server: srv,
		router:     r,
	}
	s.RegisterService()
}

type {{$.Name}} struct{
	server {{ $.InterfaceName }}
	router fiber.Router
}


{{range .Methods}}
func (s *{{$.Name}}) {{ .HandlerName }} (ctx *fiber.Ctx)error {
	var in {{.Request}}
{{if .HasPathParams }}
	if err := ctx.ParamsParse(&in); err != nil {
		return response.FiberRespFailFunc(ctx,err.Error())
	}
{{end}}
{{if eq .Method "GET" }}
	if err := ctx.QueryParser(&in); err != nil {
		return response.FiberRespFailFunc(ctx,err.Error())
	}
{{else if eq .Method "DELETE"}}
          if err := ctx.ParamsParse(&in); err != nil {
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
	for k, v := range ctx.Request.Header {
		md.Set(k, v...)
	}
	newCtx := metadata.NewIncomingContext(ctx.Request.Context(), md)
	out, err := s.server.({{ $.InterfaceName }}).{{.Name}}(newCtx, &in)
	if err != nil {
		return  response.FiberRespFailFunc(ctx,err.Error())
	}

	return response.FiberRespSuccessFunc(ctx, out)
}
{{end}}

func (s *{{$.Name}}) RegisterService() {
{{range .Methods}}
		s.router.Add("{{.Method}}", "{{.Path}}", s.{{ .HandlerName }})
{{end}}
}