function concattedSegments = concatSegments(Segments1,Segments2)

% new = [Segments1;Segments2];
fieldsS1 = fieldnames(Segments1);
fieldsS2 = fieldnames(Segments2);

FinS1notS2 = fieldsS1;
Fboth = FinS1notS2(ismember(fieldsS1,fieldsS2));
FinS1notS2(ismember(fieldsS1,fieldsS2))=[];
FinS2notS1 = fieldsS2;
FinS2notS1(ismember(fieldsS2,fieldsS1))=[];

try
    if(~isempty(FinS1notS2))
        for i=1:size(FinS1notS2,1)
           %Copy fields from S1 to concatted
           concattedSegments.(FinS1notS2{i}) = Segments1.(FinS1notS2{i});
        end
    end
    if(~isempty(FinS2notS1))
        for i=1:size(FinS2notS1,1)
           %Copy fields from S2 to concatted
           concattedSegments.(FinS2notS1{i}) = Segments2.(FinS2notS1{i});
        end
    end
    if(~isempty(Fboth))
        for i=1:size(Fboth,1)
            % Merge fields that exist in both structures
            if isstruct(Segments1.(Fboth{i}))
                subfields = fieldnames(Segments1.(Fboth{i}));
            elseif isstruct(Segments2.(Fboth{i}))
                subfields = fieldnames(Segments2.(Fboth{i}));
            else
                % Its not a struct, hmm than it should at leat be identical
                if Segments1.(Fboth{i}) == Segments2.(Fboth{i})
                    concattedSegments.(Fboth{i}) = Segments1.(Fboth{i});
                    continue;
                else
                    error('Element not a struct but not identical');
                end
            end

            for j=1:length(subfields)
                try
                    segments1 = Segments1.(Fboth{i}).(subfields{j});
                catch
                    segments1 = {};
                end

                try
                    segments2 = Segments2.(Fboth{i}).(subfields{j});
                catch
                    segments2 = {};
                end
                    concattedSegments.(Fboth{i}).(subfields{j}) = [segments1,segments2];
            end
        end
    end
catch e
    error(['Something went wrong while concatting segments: ' ,e.message]);
    concattedSegments = {};
end


