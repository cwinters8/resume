package convert

import (
	"embed"
	"flag"
	"fmt"
	"html/template"
	"os"
	"time"

	"github.com/gomarkdown/markdown"
)

func MDToHTML(fs embed.FS, input string, outputDir string) error {
	// read md file
	md, err := os.ReadFile(input)
	if err != nil {
		return fmt.Errorf("failed to read file %s: %w", input, err)
	}
	// convert md to html
	resumeHTML := markdown.ToHTML(md, nil, nil)
	// parse html with templates
	layout, err := template.New("layout.html").ParseFS(fs, "templates/layout.html")
	if err != nil {
		return fmt.Errorf("failed to parse fs templates: %w", err)
	}
	if _, err := layout.New("resume").Parse(string(resumeHTML)); err != nil {
		return fmt.Errorf("failed to parse resume html: %w", err)
	}
	fmt.Println(layout.DefinedTemplates())
	// place html output in local dir
	now := time.Now().Local().Format(time.RFC3339)
	dir := fmt.Sprintf("%s/resume_%s", outputDir, now)
	if err := os.MkdirAll(dir, 0755); err != nil {
		return fmt.Errorf("failed to create output dir: %w", err)
	}
	fileName := fmt.Sprintf("%s/resume.html", dir)
	file, err := os.Create(fileName)
	if err != nil {
		return fmt.Errorf("failed to create file %s: %w", fileName, err)
	}
	defer file.Close()
	if err := layout.Execute(file, nil); err != nil {
		return fmt.Errorf("failed to execute template: %w", err)
	}
	// copy asset files to local output dir
	assetsDir := "assets"
	assets, err := fs.ReadDir(assetsDir)
	if err != nil {
		return fmt.Errorf("failed to read assets dir: %w", err)
	}
	for _, asset := range assets {
		name := asset.Name()
		if !asset.IsDir() {
			contents, err := fs.ReadFile(fmt.Sprintf("%s/%s", assetsDir, name))
			if err != nil {
				return fmt.Errorf("failed to read file %s: %w", name, err)
			}
			f := fmt.Sprintf("%s/%s", dir, name)
			if err := os.WriteFile(f, contents, 0644); err != nil {
				return fmt.Errorf("failed to write file %s: %w", f, err)
			}
		} else {
			fmt.Printf("not currently handling asset directories, so %s and its contents will be skipped\n", name)
		}
	}
	return nil
}

//go:embed assets
var assets embed.FS

func ConvertCLI() error {
	var outputDir string
	var inputFile string
	flag.StringVar(&outputDir, "out", "output", "directory to place generated subdirectories and artifacts")
	flag.StringVar(&inputFile, "in", "resume.md", "path to input file, which must be in markdown format")
	flag.Parse()
	fmt.Printf("using `%s` as input\noutput artifacts will be placed in `%s`\n", inputFile, outputDir)
	if err := MDToHTML(assets, inputFile, outputDir); err != nil {
		return fmt.Errorf("failed to convert md to html: %w", err)
	}
	fmt.Printf("successfully converted %s\n", inputFile)
	return nil
}
