(: to do this could be modified to allow changing of individual files that have been added or are modified:)

declare function local:files($before, $after, $owner, $repo, $access_token){

  let $url := "https://api.github.com/repos/" || $owner ||"/" || $repo || "/compare/" || $before ||"..." || $after || "?access_token=" || $access_token
  let $request := <http:request method="GET" href="{$url}" timeout="30"/>
  let $response := http:send-request($request)
  let $shortid := $repo
  let $top_level_collection := local:topLevelCollectionQuery($shortid)
  let $save-path := if ($top_level_collection = $repo) then
        let $result := "/db/apps/scta-data/" || $repo || "/"
        return $result
      else
        let $result := "/db/apps/scta-data/" || $top_level_collection || "/" || $repo || "/"
        return $result


  let $files := if ($response[1]/@status = "200") then
      let $json := parse-json(util:binary-to-string($response[2]))
      return $json?files?*
    else
      let $json := parse-json(util:binary-to-string($response[2]))
      return $json


    for $file in $files
      let $new-save-path := if (contains($file?filename, "/")) then
          let $additional-path := tokenize($file?filename, "/")[1]
          let $result := $save-path || $additional-path || "/"
          return $result
        else
          let $result := $save-path
          return $result
      let $new-file-name := if (contains($file?filename, "/")) then
          let $result := tokenize($file?filename, "/")[2]
          return $result
        else
          let $result := $file?filename
          return $result
      return
        if ($file?status = 'added' or $file?status = 'modified') then
          let $url := $file?contents_url || "&amp;access_token=" || $access_token
          (: let $url := "https://api.github.com/repos/" || $owner ||"/" || $repo || "/contents/" || $file?filename || "?ref=" || $after || "&amp;access_token=" || $access_token :)
          let $request := <http:request method="GET" href="{$url}" timeout="30"/>
          let $response := http:send-request($request)
          let $new-content := util:base64-decode(parse-json(util:binary-to-string($response[2]))?content)
          return
            if (xmldb:collection-available($new-save-path)) then(
              <p>{$file?status}: {xmldb:store($new-save-path, $new-file-name, $new-content)}</p>
              (: <p>{$new-save-path} {$new-file-name} {$url}</p> :)
            )
            else(
              <div>
                (: <p>{xmldb:create-collection("/db/apps/scta-data/" || $top_level_collection, $new-save-path)}</p> :)
                (: <p>{$file?status}: {xmldb:store($new-save-path, $new-file-name, $new-content)}</p> :)
                <p>Collection not available: {$new-save-path} {$new-file-name}</p>
              </div>

            )
        else if ($file?status = 'removed') then
            <p>{$file?status}: {xmldb:remove($new-save-path, $new-file-name)}</p>
        else(
            <p>No files created, modified, or deleted</ p>
        )

};
