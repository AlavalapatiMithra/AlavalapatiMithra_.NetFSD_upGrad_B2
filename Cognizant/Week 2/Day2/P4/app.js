import {
    addTaskCallback,
    deleteTaskCallback,
    listTasksCallback,
    addTaskPromise,
    deleteTaskPromise,
    listTasksPromise,
    addTaskAsync,
    deleteTaskAsync,
    listTasksAsync
} from "./taskStorage.js";

addTaskCallback("Study JavaScript", (msg) => {
    console.log(`Callback: ${msg}`);

    listTasksCallback((tasks) => {
        console.log(`Callback Task List: ${tasks.join(", ")}`);
    });
});

addTaskPromise("Practice Async/Await")
    .then(msg => {
        console.log(`Promise: ${msg}`);
        return listTasksPromise();
    })
    .then(tasks => {
        console.log(`Promise Task List: ${tasks.join(", ")}`);
    });


const runAsyncVersion = async () => {

    try {
        const addMsg = await addTaskAsync("Build Project");
        console.log(`Async/Await: ${addMsg}`);

        const deleteMsg = await deleteTaskAsync("Study JavaScript");
        console.log(`Async/Await: ${deleteMsg}`);

        const tasks = await listTasksAsync();

        console.log(`
========================
     FINAL TASK LIST
========================
${tasks.map((t, i) => `${i + 1}. ${t}`).join("\n")}
========================
`);
    } catch (error) {
        console.error(`Error: ${error.message}`);
    }
};

runAsyncVersion();