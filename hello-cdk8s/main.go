package main

import (
	"fmt"

	"github.com/aws/constructs-go/constructs/v3"
	"github.com/aws/jsii-runtime-go"
	"github.com/cdk8s-team/cdk8s-core-go/cdk8s"
	"github.com/juanrh/hello-cdk8s/cons"
)

type MyChartProps struct {
	cdk8s.ChartProps
}

func NewMyChart(scope constructs.Construct, id string, props *MyChartProps) cdk8s.Chart {
	var cprops cdk8s.ChartProps
	if props != nil {
		cprops = props.ChartProps
	}
	chart := cdk8s.NewChart(scope, jsii.String(id), &cprops)

	cons.NewWebService(chart, jsii.String("hello"), &cons.WebServiceProps{
		Image:    jsii.String("paulbouwer/hello-kubernetes:1.7"),
		Replicas: jsii.Number(2),
	})
	cons.NewWebService(chart, jsii.String("ghost"), &cons.WebServiceProps{
    	Image:         jsii.String("ghost"),
    	ContainerPort: jsii.Number(2368),
	})	

	return chart
}

func main() {
	fmt.Println("Synthesizing chart")
	defer fmt.Println("Done synthesizing chart")

	app := cdk8s.NewApp(nil)
	NewMyChart(app, "hello-cdk8s", nil)
	app.Synth()
}
