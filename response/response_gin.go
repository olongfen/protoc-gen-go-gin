package response

import "github.com/gin-gonic/gin"

type GinErrorFunc func(ctx *gin.Context, err interface{}, status ...int)
type GinSuccessFunc func(ctx *gin.Context, data interface{})

var (
	GinSuccess = func(ctx *gin.Context, data interface{}) {
		ctx.AbortWithStatusJSON(200, HTTPServerResponse{Code: 0, Data: data, Message: "success"})
	}

	GinError = func(ctx *gin.Context, err interface{}, status ...int) {
		code := 200
		if len(status) > 0 {
			code = status[0]
		}
		ctx.AbortWithStatusJSON(code, HTTPServerResponse{Code: -1, Data: nil, Message: err})
	}
)

func ResetGinSuccess(fc GinSuccessFunc) {
	GinSuccess = fc
}

func ResetGinError(fc GinErrorFunc) {
	GinError = fc
}
