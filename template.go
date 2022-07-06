package main

import (
	"bytes"
	_ "embed"
	"fmt"
	"html/template"
	"strings"
)

//go:embed gin.template.go.tpl
var tpl string

//go:embed fiber.template.go.tpl
var fiberTpl string

type service struct {
	Name      string // Greeter
	FullName  string // helloworld.Greeter
	FilePath  string // api/helloworld/helloworld.proto
	mode      FrameMode
	Methods   []*method
	MethodSet map[string]*method
}

func (s *service) execute() string {
	if s.MethodSet == nil {
		s.MethodSet = map[string]*method{}
		for _, m := range s.Methods {
			m := m
			s.MethodSet[m.Name] = m
		}
	}
	buf := new(bytes.Buffer)
	var (
		tmpl *template.Template
		err  error
	)
	switch s.mode {
	default:
		tmpl, err = template.New("http").Parse(strings.TrimSpace(tpl))
	case fiber:
		tmpl, err = template.New("http").Parse(strings.TrimSpace(fiberTpl))
	}

	if err != nil {
		panic(err)
	}
	if err := tmpl.Execute(buf, s); err != nil {
		panic(err)
	}
	return buf.String()
}

// InterfaceGinName service interface name
func (s *service) InterfaceGinName() string {
	return s.Name + "GinHTTPServer"
}

func (s *service) InterfaceFiberName() string {
	return s.Name + "FiberHTTPServer"
}

type method struct {
	Name    string // SayHello
	Num     int    // 一个 rpc 方法可以对应多个 http 请求
	Request string // SayHelloReq
	Reply   string // SayHelloResp
	// http_rule
	Path         string // 路由
	Method       string // HTTP Method
	Body         string
	ResponseBody string
}

// HandlerName for gin handler name
func (m *method) HandlerName() string {
	return fmt.Sprintf("%s_%d", m.Name, m.Num)
}

// HasPathParams 是否包含路由参数
func (m *method) HasPathParams() bool {
	paths := strings.Split(m.Path, "/")
	for _, p := range paths {
		if len(p) > 0 && (p[0] == '{' && p[len(p)-1] == '}' || p[0] == ':') {
			return true
		}
	}
	return false
}

// initPathParams 转换参数路由 {xx} --> :xx
func (m *method) initPathParams() {
	paths := strings.Split(m.Path, "/")
	for i, p := range paths {
		if len(p) > 0 && (p[0] == '{' && p[len(p)-1] == '}' || p[0] == ':') {
			paths[i] = ":" + p[1:len(p)-1]
		}
	}
	m.Path = strings.Join(paths, "/")
}
