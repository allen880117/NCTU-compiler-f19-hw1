NAME = hw1-spec
$(NAME).pdf: style.css $(NAME).md
	cp -r ../imgs .
	pandoc --from gfm -t html5 --css style.css $(NAME).md --output $@ --metadata title=compiler-f19-$(NAME)
	rm -rf imgs

clean:
	rm  -rf imgs *.html $(NAME).pdf