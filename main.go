package main

import (
	_ "embed"
	"flag"
	"fmt"
	"os"
	"strings"

	"golang.org/x/net/html"
)

//go:embed templates
// var templates embed.FS

func injectTemplate(dest string) error {
	src, err := os.ReadFile(dest)
	if err != nil {
		return fmt.Errorf("failed to read file `%s`: %w", dest, err)
	}
	node, err := html.Parse(strings.NewReader(string(src)))
	if err != nil {
		return fmt.Errorf("failed to parse html from file `%s`: %w", dest, err)
	}
	for {
		// TODO: handle ErrorNode case
		if node.Type == html.ElementNode && node.Data == "head" {
			node.AppendChild(nil) // TODO: read style node from style.html and pass here
			break
		}
		// TODO: increment node to the next child or sibling
	}

	return nil
}

func copyFile(src string, dest string) error {
	in, err := os.ReadFile(src)
	if err != nil {
		return fmt.Errorf("failed to read file `%s`: %w", src, err)
	}
	if err := os.WriteFile(dest, in, 0644); err != nil {
		return fmt.Errorf("failed to write to file `%s`: %w", dest, err)
	}
	return nil
}

func main() {
	var inputHTML string
	var outputHTML string
	flag.StringVar(&inputHTML, "in", "output/resume.html", "path to input HTML file")
	flag.StringVar(&outputHTML, "out", "output/pdf_resume.html", "path to output HTML file")
	flag.Parse()
	if err := copyFile(inputHTML, outputHTML); err != nil {
		fmt.Printf("failed to copy `%s` to `%s`: %s\n", inputHTML, outputHTML, err.Error())
		return
	}
	if err := injectTemplate(outputHTML); err != nil {
		fmt.Printf("failed to inject styles in html: %s\n", err.Error())
		return
	}
	fmt.Printf("`%s` created with styles injected\n", outputHTML)
}
