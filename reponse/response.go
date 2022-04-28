package reponse

import "github.com/gin-gonic/gin"

type ErrorFunc func(ctx *gin.Context, err interface{}, status ...int)
type SuccessFunc func(ctx *gin.Context, data interface{})

type HTTPServerResponse struct {
	Code    int         `json:"code"`
	Data    interface{} `json:"data"`
	Message interface{} `json:"message"`
}

var (
	Success = func(ctx *gin.Context, data interface{}) {
		ctx.AbortWithStatusJSON(200, HTTPServerResponse{Code: 0, Data: data, Message: "success"})
	}

	Error = func(ctx *gin.Context, err interface{}, status ...int) {
		code := 200
		if len(status) > 0 {
			code = status[0]
		}
		ctx.AbortWithStatusJSON(code, HTTPServerResponse{Code: -1, Data: nil, Message: err})
	}
)

func ResetSuccess(fc SuccessFunc) {
	Success = fc
}

func ResetError(fc ErrorFunc) {
	Error = fc
}
