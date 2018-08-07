package main

import (
	"flag"
	"fmt"
	"runtime"
	"strings"
	"os"
	"regexp"
	"github.com/ipipdotnet/datx-go"
	"path"
	"github.com/olekukonko/tablewriter"
)

var (
	Build = "devel"

	V = flag.Bool("version", false, "show version")
	H = flag.Bool("help", false, "show this help")

	city *datx.City
	result [][]string
)

func main() {
	flag.Parse()

	if !flag.Parsed() {
		flag.Usage()
		return
	}

	if *V {
		fmt.Println("ip")
		fmt.Println("  version   :", Build)
		fmt.Println("  go version:", runtime.Version())
		return
	}

	if *H {
		flag.Usage()
		return
	}

	_, file, _, _ := runtime.Caller(0)
	daxFile := path.Join(path.Dir(file), "17monipdb.datx")

	var err error
	city, err = datx.NewCity(daxFile)
	if err != nil {
		fmt.Println(err)
		return
	}

	if len(os.Args[1:]) == 0 {
		fmt.Println("Usage:")
		fmt.Println("  ", os.Args[0], "[IP]")
		return
	}

	reg := regexp.MustCompile(`^\d+\.\d+\.\d+\.\d+$`)

	ips := strings.Join(os.Args[1:], ",")
	iparr := strings.Split(ips, ",")
	for _, ip := range iparr {
		ip = strings.TrimSpace(ip)
		if ip != "" && reg.Match([]byte(ip)) {
			parse(ip)
		}
	}

	if len(result) > 0 {
		table := tablewriter.NewWriter(os.Stdout)
		table.SetHeader([]string{"Country", "Province", "City"})
		for _, v := range result {
			table.Append(v)
		}
		table.Render()
	}
}

func parse(ip string) {
	loc, err := city.FindLocation(ip)
	if err != nil {
		fmt.Println("err parse:", ip, ", err:", err)
		return
	}

	result = append(result, []string{
		loc.Country,
		loc.Province,
		loc.City,
	})
}
