type {{ $.InterfaceName }} interface {
{{range .MethodSet}}
	{{.Name}}(context.Context, *{{.Request}}) (*{{.Reply}}, error)
{{end}}
}

type ErrorFunc func(ctx *gin.Context,err interface{},status ...int)
type SuccessFunc func(ctx *gin.Context,data interface{})

type default{{ $.InterfaceName }}Resp struct{
    Code int `json:"code"`
    Data interface{} `json:"data"`
    Message interface{} `json:"message"`
}

var( defaultSuccess = func(ctx *gin.Context,data interface{}){
    ctx.AbortWithStatusJSON(200, default{{ $.InterfaceName }}Resp{Code: 0, Data: data, Message: "success"})
}

defaultError = func(ctx *gin.Context,err interface{},status ...int){
    code := 200
	if len(status) > 0 {
		code = status[0]
	}
	ctx.AbortWithStatusJSON(code, default{{ $.InterfaceName }}Resp{Code: -1, Data: data, Message: err})
    }

)



func ResetSuccess(fc SuccessFunc) {
	defaultSuccess = fc
}

func ResetError(fc ErrorFunc) {
    defaultError = fc
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
		defaultError(ctx, err.Error())
		return
	}
{{end}}
{{if eq .Method "GET" "DELETE" }}
	if err := ctx.ShouldBindQuery(&in); err != nil {
		defaultError(ctx, err.Error())
		return
	}
{{else if eq .Method "POST" "PUT" }}
	if err := ctx.ShouldBindJSON(&in); err != nil {
		defaultError(ctx, err.Error())
		return
	}
{{else}}
	if err := ctx.ShouldBind(&in); err != nil {
		defaultError(ctx, err.Error())
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
		defaultError(ctx, err.Error())
		return
	}

	defaultSuccess(ctx, out)
}
{{end}}

func (s *{{$.Name}}) RegisterService() {
{{range .Methods}}
		s.router.Handle("{{.Method}}", "{{.Path}}", s.{{ .HandlerName }})
{{end}}
}