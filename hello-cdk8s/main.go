package main

import (
	"errors"
	"io/ioutil"
	"log"
	"os"

	"github.com/aws/constructs-go/constructs/v3"
	"github.com/aws/jsii-runtime-go"
	"github.com/cdk8s-team/cdk8s-core-go/cdk8s"
	"github.com/juanrh/hello-cdk8s/cons"
	"sigs.k8s.io/yaml"
)

const (
	valuesFile = "./values.yml"
)

var (
	defaultMyChartValues = MyChartValues{
		LaunchGhostService: true,
		HelloServiceReplicas: 2,
	}
)

type MyChartProps struct {
	cdk8s.ChartProps
	values MyChartValues
}

type MyChartValues struct {
	LaunchGhostService bool `json:"launchGhostService"`
	HelloServiceReplicas uint `json:"helloServiceReplicas"`
}

func NewMyChart(scope constructs.Construct, id string, props *MyChartProps) cdk8s.Chart {
	var cprops cdk8s.ChartProps
	if props != nil {
		cprops = props.ChartProps
	}
	chart := cdk8s.NewChart(scope, jsii.String(id), &cprops)

	cons.NewWebService(chart, jsii.String("hello"), &cons.WebServiceProps{
		Image:    jsii.String("paulbouwer/hello-kubernetes:1.7"),
		Replicas: jsii.Number(float64(props.values.HelloServiceReplicas)),
	})
	if props.values.LaunchGhostService {
		cons.NewWebService(chart, jsii.String("ghost"), &cons.WebServiceProps{
			Image:         jsii.String("ghost"),
			ContainerPort: jsii.Number(2368),
		})
	}
	
	return chart
}


func setupLogging() {
    log.SetPrefix("hello-cdk8s: ")
    log.SetFlags(0)
}

func getChartProps() (*MyChartProps, error) {
	_, err := os.Stat(valuesFile)
	if errors.Is(err, os.ErrNotExist) {
		log.Println("Using default values")
		return &MyChartProps{
			values: defaultMyChartValues,
		}, nil
	}
	if err != nil {
		return nil, err
	}
	log.Println("Using custom values")
	file, err := os.Open(valuesFile) 
	defer func() {
        if err = file.Close(); err != nil {
            log.Fatal(err)
        }
    }()
	if err != nil {
		return nil, err
	}
	valueBytes, err := ioutil.ReadAll(file)
	if err != nil {
		return nil, err
	}
	var values MyChartValues
	err = yaml.Unmarshal(valueBytes, &values)
	if err != nil {
		return nil, err
	}
	return &MyChartProps{
		values: values,
	}, nil
}

func main() {
	setupLogging()
	log.Println("Synthesizing chart")
	defer log.Println("Done synthesizing chart")

	app := cdk8s.NewApp(nil)
	props, err := getChartProps()
	if err != nil {
		log.Fatalln(err)
	}
	NewMyChart(app, "hello-cdk8s", props)

	j, _ := yaml.Marshal(props.values)
	log.Printf("Using values %q", j)


	app.Synth()
}
