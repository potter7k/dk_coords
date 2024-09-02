function MathLegth(n)
	return math.ceil(n * 100) / 100
end

function UpdateDescription(title, description)
    Ui:Send({
        updateDescription = {
            title = title,
            description = description,
        }
    })
end