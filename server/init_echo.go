package main

import (
	"fmt"
	"net/http"
	"os"

	"github.com/go-playground/validator"
	"github.com/labstack/echo"
	"github.com/labstack/echo/middleware"
)

type customValidator struct {
	validator *validator.Validate
}

func (cv *customValidator) Validate(i interface{}) error {
	fmt.Printf("Validate %+v", i)
	return cv.validator.Struct(i)
}

type APIError struct {
	Code    int
	Message string
}

func JSONErrorHandler(err error, c echo.Context) {
	code := http.StatusInternalServerError
	msg := err.Error()

	if he, ok := err.(*echo.HTTPError); ok {
		code = he.Code
		msg = http.StatusText(he.Code)
	}

	apierr := APIError{Code: code, Message: msg}

	if !c.Response().Committed {
		c.JSON(code, apierr)
	}
	c.Logger().Error(err)
}

func initEcho(e *echo.Echo) {
	//e.HideBanner = true
	e.HidePort = true

	// Middleware
	logger := middleware.LoggerWithConfig(middleware.LoggerConfig{
		Format: logFormat(),
		Output: os.Stdout,
	})
	e.Use(logger)
	e.Use(middleware.Recover())

	e.Validator = &customValidator{validator: validator.New()}

	e.HTTPErrorHandler = JSONErrorHandler
}

func logFormat() string {
	// Refer to https://github.com/tkuchiki/alp
	var format string
	format += "time:${time_rfc3339}\t"
	format += "status:${status}\t"
	format += "uri:${uri}\t"
	format += "host:${remote_ip}\t"
	format += "forwardedfor:${header:x-forwarded-for}\t"
	format += "req:-\t"
	format += "method:${method}\t"
	format += "size:${bytes_out}\t"
	format += "referer:${referer}\t"
	format += "reqtime_ns:${latency}\t"
	format += "cache:-\t"
	format += "runtime:-\t"
	format += "apptime:-\t"
	format += "vhost:${host}\t"
	format += "reqtime_human:${latency_human}\t"
	format += "x-request-id:${id}\t"
	format += "host:${host}\n"

	return format
}
